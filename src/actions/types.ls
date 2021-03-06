<[
  INIT
  SET_NOTIFICATION
  RETRIEVE_USER
  SET_USER
  UPDATE_CONFIG_TUMBLR
  SET_CONFIG_TUMBLR
  UPDATE_REFS
  SET_SESSIONS
  REMOVE_SESSION
  SET_CURRENT_SESSION
  UPDATE_CURRENT_SESSION_POSTS
  UPDATE_CURRENT_SESSION_INDEX
  API_LOCK
  API_UNLOCK
  ADD_POSTS
  SET_ROUTE
  NEXT_POST
  PREV_POST
  TOGGLE_SESSION_CONFIG
]>.forEach (type)->
  try
    exports[type] = Symbol type
  catch err
    exports[type] = type
