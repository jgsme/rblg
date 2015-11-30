require! {
  react: {Component, DOM, create-element}
}

class Menu extends Component
  render: ->
    DOM.div do
      style:
        position: \fixed
        will-change: \transform
        bottom: \5%
        right: \5%
        font-size: \36px
        background-color: 'rgba(0, 0, 0, 0.3)'
        color: \#fff
        padding: '5px 10px'
      switch @props.route
      | \config =>
        DOM.i do
          style:
            margin: '0px 10px'
          className: 'fa fa-close'
          on-click: @props.move-sessions
      | \session =>
        [
          DOM.i do
            key: \menu-reblog
            style:
              margin: '0px 10px'
            className: 'fa fa-retweet'
          DOM.i do
            key: \menu-like
            style:
              margin: '0px 10px'
              color: if @props.liked then \#BC523C else \#fff
            className: 'fa fa-heart'
          DOM.i do
            key: \menu-back
            style:
              margin: '0px 10px'
            className: 'fa fa-clone'
            on-click: @props.move-sessions
        ]
      | \sessions =>
        DOM.i do
          style:
            margin: '0px 10px'
          className: 'fa fa-cog'
          on-click: @props.move-config

module.exports = Menu
