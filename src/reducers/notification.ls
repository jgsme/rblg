require! {
  \../actions/types.ls : {SET_NOTIFICATION}
}

module.exports = (state = null, action)->
  | action.type is SET_NOTIFICATION => action.notification
  | otherwise => state
