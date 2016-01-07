require! {
  \../actions/types.ls : {SET_USER}
}

module.exports = (state = null, action)->
  | action.type is SET_USER => action.user
  | otherwise => state
