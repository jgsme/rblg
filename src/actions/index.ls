require! {
  \./types.ls : {INIT, UPDATE_REFS, SET_ROUTE}
}

exports.initialize = (firebase-url)->
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
