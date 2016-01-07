require! {
  \../actions/types.ls : {UPDATE_REFS}
}

module.exports = (state = null, action)->
  | action.type is UPDATE_REFS =>
    switch action.user
    | null => null
    | otherwise =>
      {firebase, user, value-handler} = action
      user-ref =
        firebase
          .child \users
          .child user.uid
      config-tumblr-ref =
        user-ref
          .child \config_tumblr
      sessions-ref =
        user-ref
          .child \sessions

      config-tumblr-ref.on do
        \value
        value-handler \config-tumblr
      sessions-ref.on do
        \value
        value-handler \sessions
      sessions-ref.on do
        \child_removed
        value-handler \session-remove

      root: firebase
      user: user-ref
      config-tumblr: config-tumblr-ref
      sessions: sessions-ref
  | otherwise => state
