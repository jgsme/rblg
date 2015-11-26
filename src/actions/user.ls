require! {
  \./types.ls : {SET_USER}
}

exports.set-user = (user)->
  type: SET_USER
  user: user
