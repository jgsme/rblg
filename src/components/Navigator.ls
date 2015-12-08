require! {
  react: {Component, DOM}
}

class Navigator extends Component
  render: ->
    DOM.div do
      style:
        position: \fixed
        width: window.inner-width
        height: window.inner-height
        top: 0
        left: 0
      DOM.div do
        style:
          position: \absolute
          top: 0
          left: 0
          width: \30%
          height: \100%
        on-click: @props.prev-post
      DOM.div do
        style:
          position: \absolute
          top: 0
          right: 0
          width: \30%
          height: \100%
        on-click: @props.next-post

module.exports = Navigator
