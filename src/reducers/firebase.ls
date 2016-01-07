require! {
  firebase: Firebase
  \../actions/types.ls : {INIT}
}

module.exports = (state = null, action)->
  | action.type is INIT => new Firebase action.firebase-url
  | otherwise => state
