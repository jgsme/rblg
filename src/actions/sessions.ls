require! {
  pouchdb
  \./types.ls : {SET_SESSIONS, SET_CURRENT_SESSION, REMOVE_SESSION}
  \./notification.ls : {notify}
}

exports.set-sessions = (sessions)->
  type: SET_SESSIONS
  sessions: sessions

exports.remove-session = (_, key)->
  type: REMOVE_SESSION
  key: key

exports.set-current-session = (key)->
  type: SET_CURRENT_SESSION
  key: key

exports.new-session = -> (dispatch, get-state)->
  {refs} = get-state!

  refs
    .sessions
    .push do
      created-at: new Date!.get-time!
      name: 'unnamed session'
      length: 0
      (err)-> if err? then dispatch notify err

exports.delete-session = (key, dispatch, get-state)-->
  {refs} = get-state!
  refs
    .sessions
    .child key
    .remove (err)->
      if err? then return dispatch notify err
      new pouchdb "session-#{key}"
      .destroy!
      .then -> dispatch notify \session-deleted
      .catch (err)-> dispatch notify err

exports.rename-session = (key, new-name, dispatch, get-state)-->
  {refs} = get-state!
  refs
    .sessions
    .child key
    .update do
      name: new-name
