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
  UPDATE_CURRENT_SESSION
  API_LOCK
  API_UNLOCK
  ADD_POSTS
  SET_ROUTE
  NEXT_POST
  PREV_POST
]>.forEach (type)->
  try
    exports[type] = Symbol type
  catch err
    exports[type] = type