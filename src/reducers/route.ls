require! {
  \../actions/types.ls : {SET_ROUTE}
}

module.exports = (state = \sessions, action)->
  | action.type is SET_ROUTE => action.route
  | otherwise => state
