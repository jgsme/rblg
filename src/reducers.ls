require! {
  redux: {combine-reducers}
  firebase: Firebase
  \lodash.assign : assign
  pouchdb
  \./actions/types.ls : action-types
}

inits =
  config-tumblr:
    consumer_key: ''
    consumer_secret: ''
    token: ''
    token_secret: ''
    base_hostname: ''

module.exports =
  combine-reducers do
    route: (state = \sessions, action)->
      | action.type is action-types.SET_ROUTE => action.route
      | otherwise => state
    firebase: (state = null, action)->
      | action.type is action-types.INIT => new Firebase action.firebase-url
      | otherwise => state
    notification: (state = null, action)->
      | action.type is action-types.SET_NOTIFICATION => action.notification
      | otherwise => state
    refs: (state = null, action)->
      | action.type is action-types.UPDATE_REFS =>
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

          config-tumblr-ref.on do
            \value
            value-handler \config-tumblr

          root: firebase
          user: user-ref
          config-tumblr: config-tumblr-ref
      | otherwise => state
    user: (state = null, action)->
      | action.type is action-types.SET_USER => action.user
      | otherwise => state
    config-tumblr: (state = inits.config-tumblr, action)->
      | action.type is action-types.UPDATE_CONFIG_TUMBLR =>
        state[action.key] = action.value
        assign {}, state
      | action.type is action-types.SET_CONFIG_TUMBLR =>
        if action.config-tumblr is null
          inits.config-tumblr
        else
          action.config-tumblr
      | otherwise => state
    dbs: (state = null, action)->
      | action.type is action-types.INIT =>
        sessions:
          new pouchdb do
            \sessions
            adapter: \websql
      | action.type is action-types.SET_CURRENT_SESSION =>
        assign do
          {}
          state
          current-session:
            new pouchdb do
              "session-#{action.key}"
              adapter: \websql
      | otherwise => state
    sessions: (state = [], action)->
      | action.type is action-types.SET_SESSIONS =>
        if action.sessions isnt null
          action.sessions.map (.doc)
        else
          state
      | otherwise => state
    current-session: (state = null, action)->
      | action.type is action-types.UPDATE_CURRENT_SESSION =>
        current-index: action.current-index
        posts: action.posts
      | action.type is action-types.ADD_POSTS =>
        assign do
          {}
          state
          posts: state.posts.concat action.posts
      | action.type is action-types.NEXT_POST =>
        assign do
          {}
          state
          current-index: state.current-index + 1
      | action.type is action-types.PREV_POST =>
        next = state.current-index - 1
        if next < 0 then next = 0
        assign do
          {}
          state
          current-index: next
      | otherwise => state
