require! {
  react: {Component, DOM, create-element}
}

class Menu extends Component
  render: ->
    DOM.div do
      style:
        position: \absolute
        bottom: \5%
        right: \5%
        font-size: \36px
        background-color: 'rgba(0, 0, 0, 0.3)'
        color: \#fff
        padding: '5px 10px'
      DOM.i do
        style:
          margin: '0px 10px'
        className: 'fa fa-retweet'
      DOM.i do
        style:
          margin: '0px 10px'
        className: 'fa fa-heart'
      switch @props.route
      | \config =>
        DOM.i do
          style:
            margin: '0px 10px'
          className: 'fa fa-close'
          on-click: @props.move-sessions
      | otherwise =>
        DOM.i do
          style:
            margin: '0px 10px'
          className: 'fa fa-cog'
          on-click: @props.move-config

module.exports = Menu
