require! {
  react: {Component, DOM}
}

class UserAuthButton extends Component
  render: ->
    switch @props.user
    | null =>
      DOM.button do
        on-click: @props.auth
        \auth
    | otherwise =>
      DOM.button do
        on-click: @props.unauth
        \unauth

module.exports = UserAuthButton
