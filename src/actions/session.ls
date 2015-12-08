require! {
  \./types.ls : {ADD_POSTS, UPDATE_CURRENT_SESSION, API_LOCK, API_UNLOCK, PREV_POST, NEXT_POST}
  \./notification.ls : {notify, notify-with-uid}
  \./sessions.ls : {set-current-session}
  \../utils.ls : {dashboard-handler, dupulicate-resolver}
}

if fetch is undefined then fetch = require \isomorphic-fetch

exports.add-posts = add-posts = (posts)->
  type: ADD_POSTS
  posts: posts

exports.lock-api = lock-api = ->
  type: API_LOCK

exports.unlock-api = unlock-api = ->
  type: API_UNLOCK

exports.save-posts = save-posts = (posts, dispatch, get-state)-->
  {current-session} = get-state!
  current-session
    .db
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
        dispatch apply-posts json.data
        dispatch unlock-api!
        callback!
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
  {current-session} = get-state!
  dispatch lock-api!
  dispatch do
    notify-with-uid do
      type: \init
      uid: \init
  dispatch do
    load-posts do
      is-init: true
      key: current-session.key
      ->
        dispatch do
          notify-with-uid do
            type: \inited
            uid: \init

exports.get-posts = get-posts = -> (dispatch, get-state)->
  {current-session} = get-state!
  dispatch lock-api!
  dispatch do
    notify-with-uid do
      type: \load
      uid: \load
  dispatch do
    load-posts do
      is-inf: true
      key: current-session.key
      ->
        dispatch do
          notify-with-uid do
            type: \loaded
            uid: \load

exports.update-current-session = update-current-session = (rows, current-index)->
  type: UPDATE_CURRENT_SESSION
  posts: rows
  current-index: current-index

exports.check-current-session = check-current-session = (key, cache, dispatch, get-state)-->
  {sessions} = get-state!
  current-session =
    sessions
      .filter (session)-> session.id is key
      .0
  if current-session.length is 0 then return dispatch init-posts!
  if cache.length is 0 then dispatch get-posts!

exports.save-index = save-index = (num, dispatch, get-state)-->
  {current-session} = get-state!
  {db} = current-session
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
  if current-session.current-index > current-session.posts.length - 80 and !current-session.api-lock
    dispatch get-posts!

exports.scroll-top = scroll-top = -> (dispatch, get-state)-> window.scroll-to 0, 0

exports.next-post = -> (dispatch, get-state)->
  dispatch do
    type: NEXT_POST
  dispatch scroll-top!
  {current-session} = get-state!
  dispatch save-index current-session.current-index
  dispatch check-rest-post!

exports.prev-post = -> (dispatch, get-state)->
  dispatch do
    type: PREV_POST
  dispatch scroll-top!
  {current-session} = get-state!
  dispatch save-index current-session.current-index

exports.open-post = -> (dispatch, get-state)->
  {current-session} = get-state!
  post = current-session.posts[current-session.current-index]
  window.open post.post_url

reaction-to-post = (type, dispatch, get-state)-->
  {user, current-session} = get-state!
  post = current-session.posts[current-session.current-index]
  dispatch do
    notify-with-uid do
      type: type
      uid: post.id_raw
  opt =
    id: post.id_raw
    reblog_key: post.reblog_key
  fetch "/api/#{type}?uid=#{user.uid}&token=#{user.token}&opt=#{JSON.stringify opt}"
    .then (res)-> res.json!
    .then (json)->
      | json.status is \ok =>
        dispatch notify-with-uid do
          type: "#{type}ed"
          uid: post.id_raw
      | json.status is \error =>
        console.error json.message
        dispatch notify json.message

exports.reblog = -> (dispatch, get-state)->
  dispatch reaction-to-post \reblog

exports.like = -> (dispatch, get-state)->
  dispatch reaction-to-post \like

exports.start-session = start-session = (key, current-index, dispatch, get-state)-->
  {current-session} = get-state!
  current-session
    .db
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
      dispatch check-current-session key, rows

exports.attach-session = (key, dispatch, get-state)-->
  dispatch set-current-session key
  {current-session} = get-state!
  current-session
    .db
    .get \$current-index
    .then (doc)-> dispatch start-session key, doc.num
    .catch (err)->
      current-session
        .db
        .put do
          _id: \$current-index
          num: 0
      dispatch start-session key, 0
