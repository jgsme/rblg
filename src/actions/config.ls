require! {
  \./types.ls : {UPDATE_CONFIG_TUMBLR, SET_CONFIG_TUMBLR}
  \./notification.ls : {notify}
  \./index.ls : {set-route}
}

exports.update-config-tumblr = (key, value)->
  type: UPDATE_CONFIG_TUMBLR
  key: key
  value: value

exports.set-config-tumblr = (config-tumblr)->
  type: SET_CONFIG_TUMBLR
  config-tumblr: config-tumblr

exports.save-config-tumblr = -> (dispatch, get-state)->
  {refs, config-tumblr} = get-state!
  refs
    .config-tumblr
    .set config-tumblr, (err)->
      | err? => dispatch notify err
      | otherwise =>
        dispatch notify \config-saved
        dispatch set-route \sessions
