require! {
  pouchdb
  \./types.ls : {SET_SESSIONS, SET_CURRENT_SESSION}
  \./notification.ls : {notify}
}

exports.set-sessions = set-sessions = (sessions)->
  type: SET_SESSIONS
  sessions: sessions

exports.set-current-session = set-current-session = (key)->
  type: SET_CURRENT_SESSION
  key: key

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
    dispatch notify \session-deleted
    dispatch update-sessions!
  .catch (err)-> dispatch notify err
