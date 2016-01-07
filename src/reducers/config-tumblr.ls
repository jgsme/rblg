require! {
  \lodash.assign : assign
  \../actions/types.ls : {UPDATE_CONFIG_TUMBLR, SET_CONFIG_TUMBLR}
}

init =
  consumer_key: ''
  consumer_secret: ''
  token: ''
  token_secret: ''
  base_hostname: ''
  blog_name: ''

module.exports = (state = init, action)->
  | action.type is UPDATE_CONFIG_TUMBLR =>
    state[action.key] = action.value
    assign {}, state
  | action.type is SET_CONFIG_TUMBLR =>
    if action.config-tumblr is null
      inits.config-tumblr
    else
      assign do
        {}
        state
        action.config-tumblr
        blog_name: action.config-tumblr.base_hostname.replace /\.tumblr\.com/, ''
  | otherwise => state
