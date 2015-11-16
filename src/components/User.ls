require! {
  react: {Component, DOM, create-element}
  \./user/AuthButton.ls
  \./user/ConfigPane.ls
}

class User extends Component
  render: ->
    DOM.div do
      className: \user-container
      create-element do
        AuthButton
        user: @props.user
        auth: @props.auth
        unauth: @props.unauth
      create-element do
        ConfigPane
        key: \user-config
        user: @props.user
        config-tumblr: @props.config-tumblr
        update-config-tumblr: @props.update-config-tumblr
        save-config-tumblr: @props.save-config-tumblr

module.exports = User
