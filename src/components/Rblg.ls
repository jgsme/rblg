require! {
  react: {Component, DOM, create-element}
  \react-redux : {connect}
  \react-notification-system : Notification
  \../actions/index.ls : {initialize, set-route}
  \../actions/notification.ls : {set-notification}
  \../actions/auth.ls : {check-auth, auth, unauth}
  \../actions/sessions.ls : {update-sessions, new-session, delete-session, rename-session}
  \../actions/session.ls : {attach-session, next-post, prev-post, reblog, like, toggle-config, open-post}
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
        width: \100%
        position: \absolute
        top: 0
        left: 0
        margin-bottom: \30%
      create-element do
        Notification
        ref: \notification
        style:
          Containers:
            DefaultStyle:
              max-width: \40%
      create-element do
        Menu
        route: @props.route
        liked: @props.current-session.liked
        move-config: ~> @props.dispatch set-route \config
        toggle-config: ~> @props.dispatch toggle-config!
        reblog: ~> @props.dispatch reblog!
        like: ~> @props.dispatch like!
        next-post: ~> @props.dispatch next-post!
        prev-post: ~> @props.dispatch prev-post!
      switch @props.route
      | \sessions =>
        create-element do
          Sessions
          sessions: @props.sessions
          new-session: ~> @props.dispatch new-session!
          attach-session: (session-id)~> ~>
            @props.dispatch attach-session session-id
            @props.dispatch set-route \session
          rename-session: (session-id)~> (event)~>
            if event.key-code is 13
              event.target.blur!
              @props.dispatch rename-session session-id, event.target.value
          delete-session: (session-id)~> ~> @props.dispatch delete-session session-id
      | \session =>
        create-element do
          Session
          session: @props.current-session
          open-post: ~>
            @props.dispatch toggle-config!
            @props.dispatch open-post!
          move-sessions: ~>
            @props.dispatch toggle-config!
            @props.dispatch set-route \sessions
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
