require! {
  redux: {combine-reducers}
  \./reducers/route.ls
  \./reducers/firebase.ls
  \./reducers/notification.ls
  \./reducers/refs.ls
  \./reducers/user.ls
  \./reducers/config-tumblr.ls
  \./reducers/sessions.ls
  \./reducers/current-session.ls
}

module.exports =
  combine-reducers do
    route: route
    firebase: firebase
    notification: notification
    refs: refs
    user: user
    config-tumblr: config-tumblr
    sessions: sessions
    current-session: current-session
