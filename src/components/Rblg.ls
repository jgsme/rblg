require! {
  react: {Component, DOM, create-element}
  \react-redux : {connect}
  \react-notification-system : Notification
  \../actions.ls
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
      |> actions.initialize
      |> @props.dispatch

  component-did-mount: ->
    @props.dispatch actions.set-notification @refs.notification
    @props.dispatch actions.check-auth!

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
        move-config: ~> @props.dispatch actions.set-route \config
        move-sessions: ~> @props.dispatch actions.set-route \sessions
        move-session: ~> @props.dispatch actions.set-route \session
      switch @props.route
      | \sessions =>
        create-element do
          Sessions
          sessions: @props.sessions
          update-sessions: ~> @props.dispatch actions.update-sessions!
          new-session: ~> @props.dispatch actions.new-session!
          attach-session: (session-id)~> ~>
            @props.dispatch actions.attach-session session-id
            @props.dispatch actions.set-route \session
      | \session =>
        create-element do
          Session
          session: @props.current-session
          next-post: ~> @props.dispatch actions.next-post!
          prev-post: ~> @props.dispatch actions.prev-post!
      | \config =>
        create-element do
          User
          user: @props.user
          config-tumblr: @props.config-tumblr
          check-auth: ~> @props.dispatch actions.check-auth!
          auth: ~> @props.dispatch actions.auth!
          unauth: ~> @props.dispatch actions.unauth!
          update-config-tumblr: (key, value)~> @props.dispatch actions.update-config-tumblr key, value
          save-config-tumblr: ~> @props.dispatch actions.save-config-tumblr!

module.exports =
  connect do
    (state)-> state
  <| Rblg
