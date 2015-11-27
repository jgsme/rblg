require! {
  \./types.ls : {INIT, UPDATE_REFS, SET_ROUTE}
  \./session.ls : {next-post, prev-post, reblog}
}

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
