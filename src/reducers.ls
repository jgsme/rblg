require! {
  redux: {combine-reducers}
  firebase: Firebase
  \lodash.assign : assign
  \./actions.ls
}

module.exports =
  combine-reducers do
    firebase: (state = null, action)->
      | action.type is actions.INIT => new Firebase \FIREBASE_URL
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
          config-ref =
            firebase
              .child \users
              .child user.uid
              .child \config
          config-ref.on do
            \value
            value-handler \config

          root: firebase
          user: user-ref
          config: config-ref
      | otherwise => state
    user: (state = null, action)->
      | action.type is actions.SET_USER => action.user
      | otherwise => state
    config: (state = {}, action)->
      | action.type is actions.UPDATE_CONFIG =>
        state[action.key] = action.value
        assign {}, state
      | action.type is actions.SET_CONFIG => action.config
      | otherwise => state
