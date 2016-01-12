require! {
  \lodash.assign : assign
  pouchdb
  \../actions/types.ls : {UPDATE_CURRENT_SESSION, SET_CURRENT_SESSION, API_LOCK, API_UNLOCK, ADD_POSTS, NEXT_POST, PREV_POST, TOGGLE_SESSION_CONFIG}
}

init =
  current-index: 0
  posts: []
  liked: false
  is-photoset: false
  is-show-config: false
  api-lock: false
  db: null

module.exports = (state = init, action)->
  | action.type is UPDATE_CURRENT_SESSION =>
    assign do
      {}
      state
      current-index: action.current-index
      posts: action.posts
      liked: action.posts[action.current-index]?.liked
      is-photoset: action.posts[action.current-index]?.photos?.length > 1
  | action.type is SET_CURRENT_SESSION =>
    assign do
      {}
      state
      key: action.key
      db:
        new pouchdb do
          "session-#{action.key}"
          adapter: \idb
  | action.type is API_LOCK =>
    assign do
      {}
      state
      api-lock: true
  | action.type is API_UNLOCK =>
    assign do
      {}
      state
      api-lock: false
  | action.type is ADD_POSTS =>
    assign do
      {}
      state
      posts: state.posts.concat action.posts
  | action.type is NEXT_POST =>
    next = state.current-index + 1
    if next >= state.posts.length then next = state.current-index
    assign do
      {}
      state
      current-index: next
      liked: state.posts[next].liked
      is-photoset: state.posts[next].photos?.length > 1
  | action.type is PREV_POST =>
    next = state.current-index - 1
    if next < 0 then next = 0
    assign do
      {}
      state
      current-index: next
      liked: state.posts[next].liked
      is-photoset: state.posts[next].photos?.length > 1
  | action.type is TOGGLE_SESSION_CONFIG =>
    assign do
      {}
      state
      is-show-config: !state.is-show-config
  | otherwise => state
