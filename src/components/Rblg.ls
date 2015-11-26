require! {
  react: {Component, DOM, create-element}
  \react-redux : {connect}
  \react-notification-system : Notification
  \../actions/index.ls : {initialize, set-route}
  \../actions/notification.ls : {set-notification}
  \../actions/auth.ls : {check-auth, auth, unauth}
  \../actions/sessions.ls : {update-sessions, new-session, delete-session}
  \../actions/session.ls : {attach-session, next-post, prev-post, reblog}
  \../actions/config.ls : {update-config-tumblr, save-config-tumblr}
  \./Menu.ls
  \./User.ls
  \./Sessions.ls
  \./Session.ls
}

class Rblg extends Component
  component-will-mount: ->
    document
      .get-element-by-id \firebaseUrl
      .get-attribute \data-url
      |> initialize
      |> @props.dispatch

  component-did-mount: ->
    @props.dispatch set-notification @refs.notification
    @props.dispatch check-auth!

  render: ->
    DOM.div do
      className: \container
      style:
        width: "#{window.inner-width}px"
        height: "#{window.inner-height}px"
        position: \absolute
        top: 0
        left: 0
      create-element do
        Notification
        ref: \notification
      create-element do
        Menu
        route: @props.route
        move-config: ~> @props.dispatch set-route \config
        move-sessions: ~> @props.dispatch set-route \sessions
        move-session: ~> @props.dispatch set-route \session
      switch @props.route
      | \sessions =>
        create-element do
          Sessions
          sessions: @props.sessions
          update-sessions: ~> @props.dispatch update-sessions!
          new-session: ~> @props.dispatch new-session!
          attach-session: (session-id)~> ~>
            @props.dispatch attach-session session-id
            @props.dispatch set-route \session
          delete-session: (session-id)~> ~> @props.dispatch delete-session session-id
      | \session =>
        create-element do
          Session
          session: @props.current-session
          next-post: ~> @props.dispatch next-post!
          prev-post: ~> @props.dispatch prev-post!
          reblog: ~> @props.dispatch reblog!
      | \config =>
        create-element do
          User
          user: @props.user
          config-tumblr: @props.config-tumblr
          check-auth: ~> @props.dispatch check-auth!
          auth: ~> @props.dispatch auth!
          unauth: ~> @props.dispatch unauth!
          update-config-tumblr: (key, value)~> @props.dispatch update-config-tumblr key, value
          save-config-tumblr: ~> @props.dispatch save-config-tumblr!

module.exports =
  connect do
    (state)-> state
  <| Rblg
