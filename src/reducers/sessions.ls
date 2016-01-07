require! {
  \lodash.assign : assign
  \../actions/types.ls : {SET_SESSIONS, REMOVE_SESSION}
}

module.exports = (state = [], action)->
  | action.type is SET_SESSIONS =>
    if action.sessions isnt null
      Object
        .keys action.sessions
        .map (key)->
          assign do
            action.sessions[key]
            id: key
        .sort (x, y)-> y.created-at - x.created-at
    else
      state
  | action.type is REMOVE_SESSION =>
    state.filter (session)-> session.id isnt action.key
  | otherwise => state
