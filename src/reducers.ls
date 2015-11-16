require! {
  redux: {combine-reducers}
  firebase: Firebase
  \lodash.assign : assign
  pouchdb
  \./actions.ls
}

inits =
  config-tumblr:
    consumer_key: ''
    consumer_secret: ''
    token: ''
    token_secret: ''

module.exports =
  combine-reducers do
    route: (state = \sessions, action)->
      | action.type is actions.SET_ROUTE => action.route
      | otherwise => state
    firebase: (state = null, action)->
      | action.type is actions.INIT => new Firebase action.firebase-url
      | otherwise => state
    notification: (state = null, action)->
      | action.type is actions.SET_NOTIFICATION => action.notification
      | otherwise => state
    refs: (state = null, action)->
      | action.type is actions.UPDATE_REFS =>
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
      | action.type is actions.SET_USER => action.user
      | otherwise => state
    config-tumblr: (state = inits.config-tumblr, action)->
      | action.type is actions.UPDATE_CONFIG_TUMBLR =>
        state[action.key] = action.value
        assign {}, state
      | action.type is actions.SET_CONFIG_TUMBLR =>
        if action.config-tumblr is null
          inits.config-tumblr
        else
          action.config-tumblr
      | otherwise => state
    dbs: (state = null, action)->
      | action.type is actions.INIT =>
        sessions: new pouchdb \sessions
      | action.type is actions.SET_CURRENT_SESSION =>
        assign do
          {}
          state
          current-session: new pouchdb "session-#{action.key}"
      | otherwise => state
    sessions: (state = [], action)->
      | action.type is actions.SET_SESSIONS =>
        if action.sessions isnt null
          action.sessions.map (.doc)
        else
          state
      | otherwise => state
    current-session: (state = null, action)->
      | action.type is actions.UPDATE_CURRENT_SESSION =>
        current-index: action.current-index
        posts: action.posts
      | action.type is actions.ADD_POSTS =>
        filtered-action-posts =
          action.posts.filter (post)->
            state.posts.reduce do
              (p, c)-> if c.id is post.id then false else true
              true
        assign do
          {}
          state
          posts: state.posts.concat filtered-action-posts
      | action.type is actions.NEXT_POST =>
        assign do
          {}
          state
          current-index: state.current-index + 1
      | action.type is actions.PREV_POST =>
        next = state.current-index - 1
        if next < 0 then next = 0
        assign do
          {}
          state
          current-index: next
      | otherwise => state
