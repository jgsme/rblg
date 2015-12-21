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
    blog_name: ''
  current-session:
    current-index: 0
    posts: []
    liked: false
    is-photoset: false
    api-lock: false
    db: null

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
          assign do
            {}
            state
            action.config-tumblr
            blog_name: action.config-tumblr.base_hostname.replace /\.tumblr\.com/, ''
      | otherwise => state
    sessions: (state = [], action)->
      | action.type is action-types.SET_SESSIONS =>
        if action.sessions isnt null
          Object
            .keys action.sessions
            .map (key)->
              assign do
                action.sessions[key]
                id: key
            .sort (x, y)-> y.created-at - x.created-at
        else
          state
      | action.type is action-types.REMOVE_SESSION =>
        state.filter (session)-> session.id isnt action.key
      | otherwise => state
    current-session: (state = inits.current-session, action)->
      | action.type is action-types.UPDATE_CURRENT_SESSION =>
        assign do
          {}
          state
          current-index: action.current-index
          posts: action.posts
          liked: action.posts[action.current-index]?.liked
          is-photoset: action.posts[action.current-index]?.photos?.length > 1
      | action.type is action-types.SET_CURRENT_SESSION =>
        assign do
          {}
          state
          key: action.key
          db:
            new pouchdb "session-#{action.key}"
      | action.type is action-types.API_LOCK =>
        assign do
          {}
          state
          api-lock: true
      | action.type is action-types.API_UNLOCK =>
        assign do
          {}
          state
          api-lock: false
      | action.type is action-types.ADD_POSTS =>
        assign do
          {}
          state
          posts: state.posts.concat action.posts
      | action.type is action-types.NEXT_POST =>
        next = state.current-index + 1
        if next >= state.posts.length then next = state.current-index
        assign do
          {}
          state
          current-index: next
          liked: state.posts[next].liked
          is-photoset: state.posts[next].photos?.length > 1
      | action.type is action-types.PREV_POST =>
        next = state.current-index - 1
        if next < 0 then next = 0
        assign do
          {}
          state
          current-index: next
          liked: state.posts[next].liked
          is-photoset: state.posts[next].photos?.length > 1
      | otherwise => state
