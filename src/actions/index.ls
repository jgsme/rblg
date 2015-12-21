require! {
  \./types.ls : {INIT, UPDATE_REFS, SET_ROUTE}
  \./session.ls : {next-post, prev-post, reblog, like, open-post}
  \./sessions.ls : {set-sessions, remove-session}
  \./config.ls : {set-config-tumblr}
}

exports.value-handler = (dispatch, type, snapshot)-->
  fn =
    switch type
    | \config-tumblr => set-config-tumblr
    | \sessions => set-sessions
    | \session-remove => remove-session
    | otherwise => null
  if fn is null then return
  val = snapshot.val!
  key = snapshot.key!
  if val is null then return
  dispatch fn val, key

keyboard-hander = (dispatch, get-state, event)-->
  {route} = get-state!
  {key-code} = event
  switch route
  | \session =>
    switch key-code
    | 74 => dispatch next-post!
    | 75 => dispatch prev-post!
    | 73 => dispatch reblog!
    | 76 => dispatch like!
    | 79 => dispatch open-post!

exports.initialize = (firebase-url, dispatch, get-state)-->
  document.add-event-listener \keydown, keyboard-hander dispatch, get-state
  dispatch do
    type: INIT
    firebase-url: firebase-url

exports.update-refs = (firebase, user, value-handler)->
  type: UPDATE_REFS
  firebase: firebase
  user: user
  value-handler: value-handler

exports.set-route = (route)->
  type: SET_ROUTE
  route: route
