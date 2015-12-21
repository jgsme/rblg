require! {
  react: {Component, DOM}
}

class UserAuthButton extends Component
  render: ->
    switch @props.user
    | null =>
      DOM.button do
        className: 'pure-button pure-button-primary'
        style:
          width: \100%
          font-size: \36px
        on-click: @props.auth
        DOM.i do
          className: 'fa fa-key'
        \Auth
    | otherwise =>
      DOM.button do
        className: 'pure-button'
        style:
          width: \100%
          font-size: \18px
          color: \#fff
          background-color: \#CA3C3C
          margin-top: \30px
        on-click: @props.unauth
        DOM.i do
          className: 'fa fa-key'
        \Unauth

module.exports = UserAuthButton
