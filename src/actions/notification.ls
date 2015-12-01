require! {
  \./types.ls : {SET_NOTIFICATION}
}

exports.set-notification = (notification)->
  type: SET_NOTIFICATION
  notification: notification

exports.notify = (type, dispatch, get-state)-->
  {notification} = get-state!
  message =
    switch type
    | \login-success =>
      message: 'Login success'
      level: \success
    | \config-saved =>
      message: 'Config saved'
      level: \success
    | \session-deleted =>
      message: 'Session deleted'
      level: \success
    | otherwise =>
      message: type.to-string!
      level: \error
      auto-dismiss: 0
  notification.add-notification message

exports.notify-with-uid = (opt, dispatch, get-state)-->
  {notification} = get-state!
  {add-notification, remove-notification} = notification
  switch opt.type
  | \reblog, \like, \init, \load =>
    add-notification do
      message: "#{opt.type}..."
      level: \info
      uid: opt.uid
      auto-dismiss: 0
  | \rebloged, \likeed, \inited, \loaded =>
    remove-notification opt.uid
    add-notification do
      message: 'Done'
      level: \success
