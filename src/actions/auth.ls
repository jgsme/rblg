require! {
  \./config.ls : {set-config-tumblr}
  \./user.ls : {set-user}
  \./index.ls : {set-route, update-refs, value-handler}
  \./notification.ls : {notify}
}

exports.check-auth = -> (dispatch, get-state)->
  {firebase} = get-state!
  user = firebase.get-auth!
  if user isnt null
    dispatch set-user user
    dispatch update-refs firebase, user, value-handler dispatch
    dispatch notify \login-success
  else
    dispatch set-route \config

exports.auth = -> (dispatch, get-state)->
  {firebase} = get-state!
  err <- firebase.authWithOAuthRedirect \github
  if err? then return dispatch fire-notification err
  user = firebase.get-auth!
  dispatch set-user user
  dispatch update-refs firebase, user, value-handler dispatch
  dispatch notify \login-success
  dispatch set-route \sessions

exports.unauth = -> (dispatch, get-state)->
  get-state!.firebase.unauth!
  dispatch set-user null
  dispatch set-config-tumblr null
  dispatch update-refs null, null, null
