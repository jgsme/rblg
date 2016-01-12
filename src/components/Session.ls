require! {
  react: {Component, DOM, create-element}
  \lodash.assign : assign
  \./Posts.ls
}

class Session extends Component
  render: ->
    DOM.div do
      style:
        width: \100%
      DOM.div do
        style:
          position: \fixed
          will-change: \transform
          top: 0
          left: 0
          background-color: 'rgba(0, 0, 0, 0.3)'
          color: \#fff
          font-size: \18px
        "#{@props.session.current-index + 1}/#{@props.session.posts.length}"
      DOM.div do
        style:
          position: \fixed
          will-change: \transform
          top: 0
          right: 0
          background-color: 'rgba(0, 0, 0, 0.3)'
          color: \#fff
          font-size: \18px
          display: if @props.session.is-photoset then \block else \none
        \Photoset
      DOM.div do
        style:
          position: \fixed
          will-change: \transform
          top: \5%
          left: \5%
          right: \5%
          padding: \1%
          background-color: 'rgba(0, 0, 0, 0.8)'
          color: \#fff
          font-size: \18px
          display: if @props.session.is-show-config then \block else \none
        DOM.p do
          on-click: @props.open-post
          style:
            cursor: \pointer
          DOM.i do
            className: 'fa fa-external-link'
            style:
              margin-right: \10px
          'Open post page'
      create-element do
        Posts
        session: @props.session

module.exports = Session
