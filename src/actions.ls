action-types =
  <[
    INIT
    RETRIEVE_USER
    SET_USER
    UPDATE_CONFIG
    SET_CONFIG
    UPDATE_REFS
  ]>
action-types.map (type)-> exports[type] = type
refs =
  action-types.reduce do
    (prev, current)->
      prev[current] = current
      prev
    {}

exports.initialize = initialize = ->
  type: refs.INIT

exports.set-user = set-user = (user, firebase)->
  type: refs.SET_USER
  user: user

exports.update-refs = update-refs = (firebase, user, value-handler)->
  type: refs.UPDATE_REFS
  firebase: firebase
  user: user
  value-handler: value-handler

exports.update-config = (key, value)->
  type: refs.UPDATE_CONFIG
  key: key
  value: value

exports.set-config = set-config = (config)->
  type: refs.SET_CONFIG
  config: config

value-handler = (dispatch, type, snapshot)-->
  | type is \config => dispatch set-config snapshot.val!

exports.check-auth = -> (dispatch, get-state)->
  {firebase} = get-state!
  user = firebase.get-auth!
  if user isnt null
    dispatch set-user user
    dispatch update-refs firebase, user, value-handler dispatch

exports.auth = -> (dispatch, get-state)->
  {firebase} = get-state!
  err <- firebase.authWithOAuthPopup \github
  if err? then return console.log err
  user = firebase.get-auth!
  dispatch set-user user
  dispatch update-refs firebase, user, value-handler dispatch

exports.unauth = -> (dispatch, get-state)->
  get-state!.firebase.unauth!
  dispatch set-user null
  dispatch set-config null
  dispatch update-refs null, null, null

exports.save-config = -> (dispatch, get-state)->
  {refs, config} = get-state!
  refs
    .config
    .set config, (err)->
      | err? => console.log err
      | otherwise => console.log 'Config updated'
