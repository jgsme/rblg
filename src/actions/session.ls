require! {
  async
  \./types.ls : {ADD_POSTS, UPDATE_CURRENT_SESSION, API_LOCK, API_UNLOCK, PREV_POST, NEXT_POST}
  \./notification.ls : {notify, notify-with-uid}
  \./sessions.ls : {set-current-session}
  \../utils.ls : {dashboard-handler, dupulicate-resolver}
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
        callback json
      else
        console.error json
        dispatch notify json.message

exports.apply-posts = apply-posts = (data, dispatch, get-state)-->
  {current-session, config-tumblr} = get-state!
  posts-candidate =
    data
      .map dashboard-handler
      .filter (isnt null)
      |> (posts)-> dupulicate-resolver current-session.posts, posts
      |> (posts)-> posts.filter (post)-> post.blog_name isnt config-tumblr.blog_name
  dispatch add-posts posts-candidate
  dispatch save-posts posts-candidate

exports.init-posts = init-posts = -> (dispatch, get-state)->
  dispatch do
    type: API_LOCK
  async.each-series do
    [0 til 12]
    (n, callback)->
      dispatch do
        load-posts do
          offset: n * 20
          (json)->
            dispatch apply-posts json.data
            callback!
    ->
      dispatch do
        type: API_UNLOCK

exports.get-posts = get-posts = (opt, dispatch, get-state)-->
  {current-session} = get-state!
  {posts} = current-session
  dispatch do
    type: API_LOCK
  dispatch do
    load-posts do
      last-id: posts[*-1].id_raw
      first-id: posts.0.id_raw
      length: posts.length
      (json)->
        if json.status is \ok
          dispatch apply-posts json.data
        else
          notify json.message
        dispatch do
          type: API_UNLOCK

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

exports.check-rest-post = check-rest-post = -> (dispatch, get-state)->
  {current-session} = get-state!
  if current-session.current-index > current-session.posts.length - 40 and !current-session.api-lock
    dispatch do
      get-posts do
        strategy: \default

exports.next-post = -> (dispatch, get-state)->
  dispatch do
    type: NEXT_POST
  {dbs, current-session} = get-state!
  dispatch save-index current-session.current-index, dbs.current-session
  dispatch check-rest-post!

exports.prev-post = -> (dispatch, get-state)->
  dispatch do
    type: PREV_POST
  {dbs, current-session} = get-state!
  dispatch save-index current-session.current-index, dbs.current-session

exports.reblog = -> (dispatch, get-state)->
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

exports.start-session = start-session = (current-index, dispatch, get-state)-->
  {dbs} = get-state!
  dbs
    .current-session
    .query do
      (doc, emit)-> if doc._id.0 isnt \$ then emit doc
      include_docs: true
    .then (res)->
      rows =
        res
          .rows
          .map (.doc)
          .sort (x, y)-> y.id_raw - x.id_raw
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
