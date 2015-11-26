require! {
  async
  \./types.ls : {ADD_POSTS, UPDATE_CURRENT_SESSION, PREV_POST, NEXT_POST}
  \./notification.ls : {notify, notify-with-uid}
  \./sessions.ls : {set-current-session}
  \../utils.ls : {dashboard-handler}
}

exports.add-posts = add-posts = (posts)->
  type: ADD_POSTS
  posts: posts

exports.save-posts = save-posts = (posts, dispatch, get-state)-->
  {dbs} = get-state!
  {current-session} = dbs
  current-session
    .bulk-docs posts
    .catch (err)->
      console.error err
      dispatch notify err

exports.load-posts = load-posts = (opt, callback, dispatch, get-state)-->
  {user, current-session} = get-state!
  fetch "/api/dashboard?uid=#{user.uid}&token=#{user.token}&opt=#{JSON.stringify opt}"
    .then (res)-> res.json!
    .then (json)->
      if json.status is \ok
        posts-candidate =
          json.data.posts
            .map dashboard-handler
            .filter (isnt null)
            |> (posts)-> dupulicate-resolver current-session.posts, posts
        dispatch add-posts posts-candidate
        dispatch save-posts posts-candidate
        callback!
      else
        console.error json
        notify json.message

exports.init-posts = init-posts = -> (dispatch, get-state)->
  async.each-series do
    [0 til 10]
    (n, callback)->
      dispatch do
        load-posts do
          offset: n * 20
          callback
    (err)->
      if err?
        console.error err
        dispatch notify err

exports.update-current-session = update-current-session = (rows, current-index)->
  type: UPDATE_CURRENT_SESSION
  posts: rows
  current-index: current-index

exports.check-current-session = check-current-session = -> (dispatch, get-state)->
  {current-session} = get-state!
  if current-session.posts.length is 0 then dispatch init-posts!

exports.save-index = save-index = (num, db, dispatch, get-state)-->
  db
    .get \$current-index
    .then (doc)->
      db
        .put do
          _id: \$current-index
          _rev: doc._rev
          num: num
    .catch (err)->
      if err.status isnt 409 # conflict
        console.error err
        dispatch notify err

exports.next-post = next-post = -> (dispatch, get-state)->
  dispatch do
    type: NEXT_POST
  {dbs, current-session} = get-state!
  dispatch save-index current-session.current-index, dbs.current-session

exports.prev-post = prev-post = -> (dispatch, get-state)->
  dispatch do
    type: PREV_POST
  {dbs, current-session} = get-state!
  dispatch save-index current-session.current-index, dbs.current-session

exports.reblog = reblog = -> (dispatch, get-state)->
  {user, current-session} = get-state!
  post = current-session.posts[current-session.current-index]
  dispatch do
    notify-with-uid do
      type: \reblogging
      uid: post.id_raw
  opt =
    id: post.id_raw
    reblog_key: post.reblog_key
  fetch "/api/reblog?uid=#{user.uid}&token=#{user.token}&opt=#{JSON.stringify opt}"
    .then (res)-> res.json!
    .then (json)->
      | json.status is \ok =>
        dispatch notify-with-uid do
          type: \rebloged
          uid: post.id_raw
      | json.status is \error =>
        console.error json.message
        dispatch notify json.message

keyboard-hander = (dispatch, get-state, event)-->
  {route} = get-state!
  {key-code} = event
  switch route
  | \session =>
    switch key-code
    | 74 => dispatch next-post!
    | 75 => dispatch prev-post!
    | 73 => dispatch reblog!
    | 76 => console.log 'l'

exports.start-session = start-session = (current-index, dispatch, get-state)-->
  {dbs} = get-state!
  document.add-event-listener \keydown, keyboard-hander dispatch, get-state
  dbs
    .current-session
    .query do
      (doc, emit)-> if doc._id.0 isnt \$ then emit doc
      include_docs: true
    .then (res)->
      rows = res.rows.map (.doc)
      dispatch update-current-session rows, current-index
      dispatch check-current-session!

exports.attach-session = (key, dispatch, get-state)-->
  dispatch set-current-session key

  {dbs, sessions} = get-state!
  {current-session} = dbs
  current-session
    .get \$current-index
    .then (doc)-> dispatch start-session doc.num
    .catch (err)->
      current-session
        .put do
          _id: \$current-index
          num: 0
      dispatch start-session 0
