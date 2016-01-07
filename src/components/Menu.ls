require! {
  react: {Component, DOM, create-element}
  \lodash.assign : assign
}

class Menu extends Component
  styles:
    anchor:
      color: \#fff
    button:
      padding: '12px 12px'
      background-color: 'rgba(0, 0, 0, 0.3)'
    container:
      position: \fixed
      will-change: \transform
      bottom: \5%
      right: 0
      left: 0
      text-align: \center
      font-size: \36px
      z-index: 1000

  render: ->
    DOM.div do
      style: @styles.container
      switch @props.route
      | \config =>
        DOM.a do
          style: @styles.anchor
          href: \#
          on-click: @props.move-sessions
          DOM.i do
            style: @styles.button
            className: 'fa fa-close'
      | \session =>
        [
          DOM.a do
            key: \menu-prev
            style: @styles.anchor
            href: \#
            on-click: @props.prev-post
            DOM.i do
              style: @styles.button
              className: 'fa fa-arrow-left'
          DOM.a do
            key: \menu-reblog
            style: @styles.anchor
            href: \#
            on-click: @props.reblog
            DOM.i do
              style: @styles.button
              className: 'fa fa-retweet'
          DOM.a do
            key: \menu-like
            style: @styles.anchor
            href: \#
            on-click: @props.like
            DOM.i do
              style:
                assign do
                  @styles.button
                  color: if @props.liked then \#BC523C else \#fff
              className: 'fa fa-heart'
          DOM.a do
            key: \menu-back
            style: @styles.anchor
            href: \#
            on-click: @props.move-sessions
            DOM.i do
              style: @styles.button
              className: 'fa fa-clone'
          DOM.a do
            key: \menu-next
            style: @styles.anchor
            href: \#
            on-click: @props.next-post
            DOM.i do
              style: @styles.button
              className: 'fa fa-arrow-right'
        ]
      | \sessions =>
        DOM.a do
          style: @styles.anchor
          href: \#
          on-click: @props.move-config
          DOM.i do
            style: @styles.button
            className: 'fa fa-cog'

module.exports = Menu
