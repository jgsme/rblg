require! {
  react: {Component, DOM, create-element}
  \./UserAuthButton.ls
  \./UserConfigPane.ls
}

class User extends Component
  component-will-mount: -> @props.check-auth!

  render: ->
    DOM.div do
      className: \user-container
      create-element do
        UserAuthButton
        user: @props.user
        auth: @props.auth
        unauth: @props.unauth
      create-element do
        UserConfigPane
        key: \user-config
        user: @props.user
        config: @props.config
        update-config: @props.update-config
        save-config: @props.save-config

module.exports = User
