require! {
  \isomorphic-fetch : fetch
  \lodash.assign : assign
  \neo-async : async
  pouchdb
}

action-types =
  <[
    INIT
    SET_NOTIFICATION
    RETRIEVE_USER
    SET_USER
    UPDATE_CONFIG_TUMBLR
    SET_CONFIG_TUMBLR
    UPDATE_REFS
    SET_SESSIONS
    SET_CURRENT_SESSION
    UPDATE_CURRENT_SESSION
    ADD_POSTS
    SET_ROUTE
    NEXT_POST
    PREV_POST
  ]>
action-types.map (type)-> exports[type] = type
actions =
  action-types.reduce do
    (prev, current)->
      prev[current] = current
      prev
    {}

exports.initialize = initialize = (firebase-url)->
  type: actions.INIT
  firebase-url: firebase-url

exports.set-notification = (notification)->
  type: actions.SET_NOTIFICATION
  notification: notification

exports.set-user = set-user = (user)->
  type: actions.SET_USER
  user: user

exports.update-refs = update-refs = (firebase, user, value-handler)->
  type: actions.UPDATE_REFS
  firebase: firebase
  user: user
  value-handler: value-handler

exports.update-config-tumblr = (key, value)->
  type: actions.UPDATE_CONFIG_TUMBLR
  key: key
  value: value

exports.set-config-tumblr = set-config-tumblr = (config-tumblr)->
  type: actions.SET_CONFIG_TUMBLR
  config-tumblr: config-tumblr

exports.set-sessions = set-sessions = (sessions)->
  type: actions.SET_SESSIONS
  sessions: sessions

exports.set-current-session = set-current-session = (key)->
  type: actions.SET_CURRENT_SESSION
  key: key

exports.set-route = set-route = (route)->
  type: actions.SET_ROUTE
  route: route

value-handler = (dispatch, type, snapshot)-->
  fn =
    switch type
    | \config-tumblr => set-config-tumblr
    | otherwise => null
  if fn is null then return
  val = snapshot.val!
  if val is null then return
  dispatch fn val

exports.fire-notification = fire-notification = (type, dispatch, get-state)-->
  {notification} = get-state!
  message =
    switch type
    | \login-success =>
      message: 'Login success'
      level: \success
    | \config-saved =>
      message: 'Config saved'
      level: \success
    | \session-deleted =>
      message: 'Session deleted'
      level: \success
    | otherwise =>
      message: type
      level: \error
      auto-dismiss: 0
  notification.add-notification message

exports.fire-notification-with-uid = fire-notification-with-uid = (opt, dispatch, get-state)-->
  {notification} = get-state!
  {add-notification, remove-notification} = notification
  switch opt.type
  | \reblogging =>
    add-notification do
      message: 'Reblogging...'
      level: \info
      uid: opt.uid
  | \rebloged =>
    remove-notification opt.uid
    add-notification do
      message: 'Reblog done'
      level: \success

exports.check-auth = -> (dispatch, get-state)->
  {firebase} = get-state!
  user = firebase.get-auth!
  if user isnt null
    dispatch set-user user
    dispatch update-refs firebase, user, value-handler dispatch
    dispatch fire-notification \login-success
  else
    dispatch set-route \config

exports.auth = -> (dispatch, get-state)->
  {firebase} = get-state!
  err <- firebase.authWithOAuthPopup \github
  if err? then return console.log err
  user = firebase.get-auth!
  dispatch set-user user
  dispatch update-refs firebase, user, value-handler dispatch
  dispatch fire-notification \login-success
  dispatch set-route \sessions

exports.unauth = -> (dispatch, get-state)->
  get-state!.firebase.unauth!
  dispatch set-user null
  dispatch set-config-tumblr null
  dispatch update-refs null, null, null

exports.save-config-tumblr = -> (dispatch, get-state)->
  {refs, config-tumblr} = get-state!
  refs
    .config-tumblr
    .set config-tumblr, (err)->
      | err? => dispatch fire-notification err
      | otherwise =>
        dispatch fire-notification \config-saved
        dispatch set-route \sessions

exports.update-sessions = update-sessions = -> (dispatch, get-state)->
  {dbs} = get-state!

  dbs
    .sessions
    .all-docs do
      include_docs: true
    .then (res)-> dispatch set-sessions res.rows

exports.new-session = -> (dispatch, get-state)->
  {dbs} = get-state!

  dbs
    .sessions
    .post do
      created-at: new Date!.get-time!
    .then (res)-> dispatch update-sessions!

exports.add-posts = add-posts = (posts)->
  type: actions.ADD_POSTS
  posts: posts

exports.save-posts = save-posts = (posts, dispatch, get-state)-->
  {dbs} = get-state!
  {current-session} = dbs
  current-session
    .bulk-docs posts
    .catch (err)-> console.log err

exports.load-posts = load-posts = (opt, callback, dispatch, get-state)-->
  {user, current-session} = get-state!
  fetch "/api/dashboard?uid=#{user.uid}&token=#{user.token}&opt=#{JSON.stringify opt}"
    .then (res)-> res.json!
    .then (json)->
      if json.status is \ok
        posts-candidate =
          json.data.posts
            .map (post)->
              switch post.type
              | \text, \photo, \quote, \link =>
                assign do
                  type: post.type
                  _id: "post-#{post.id}"
                  id_raw: post.id
                  reblog_key: post.reblog_key
                  switch post.type
                  | \text =>
                    title: post.title
                    body: post.body
                  | \photo =>
                    photos: post.photos
                    caption: post.caption
                  | \quote =>
                    text: post.text
                    source: post.source
                  | \link =>
                    title: post.title
                    url: post.url
              | otherwise => null
            .filter (isnt null)
            |> (posts)->
              posts.filter (post)->
                current-session.posts.reduce do
                  (p, c)-> if c._id is post._id then false else true
                  true
        dispatch add-posts posts-candidate
        dispatch save-posts posts-candidate
        callback!

exports.init-posts = init-posts = -> (dispatch, get-state)->
  async.each-series do
    [0 til 10]
    (n, callback)->
      dispatch load-posts do
          offset: n * 20
          callback
    (err)-> if err? then console.log err

exports.update-current-session = update-current-session = (rows, current-index)->
  type: actions.UPDATE_CURRENT_SESSION
  posts: rows
  current-index: current-index

exports.check-current-session = check-current-session = -> (dispatch, get-state)->
  {current-session} = get-state!
  if current-session.posts.length is 0 then dispatch init-posts!

exports.start-session = start-session = (current-index, dispatch, get-state)-->
  {dbs} = get-state!
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

exports.delete-session = (key, dispatch, get-state)-->
  {dbs} = get-state!
  {sessions} = dbs
  new pouchdb do
    "session-#{key}"
    adapter: \websql
  .destroy!
  .then -> sessions.get key
  .then (doc)-> sessions.remove doc
  .then ->
    dispatch fire-notification \session-deleted
    dispatch update-sessions!
  .catch (err)-> dispatch fire-notification err

save-index = (num, db)->
  db
    .get \$current-index
    .then (doc)->
      db
        .put do
          _id: \$current-index
          _rev: doc._rev
          num: num
    .catch (err)-> console.log err

exports.next-post = -> (dispatch, get-state)->
  dispatch do
    type: actions.NEXT_POST
  {dbs, current-session} = get-state!
  save-index current-session.current-index, dbs.current-session

exports.prev-post = -> (dispatch, get-state)->
  dispatch do
    type: actions.PREV_POST
  {dbs, current-session} = get-state!
  save-index current-session.current-index, dbs.current-session

exports.reblog = -> (dispatch, get-state)->
  {user, current-session} = get-state!
  post = current-session.posts[current-session.current-index]
  dispatch fire-notification-with-uid do
              type: \reblogging
              uid: post.id_raw
  opt =
    id: post.id_raw
    reblog_key: post.reblog_key
  fetch "/api/reblog?uid=#{user.uid}&token=#{user.token}&opt=#{JSON.stringify opt}"
    .then (res)-> res.json!
    .then (json)->
      | json.status is \ok =>
        dispatch fire-notification-with-uid do
          type: \rebloged
          uid: post.id_raw
      | json.status is \error => dispatch fire-notification json.message
