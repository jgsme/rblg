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
      on-touch-start: (event)~>
        @prev-x = event.changed-touches.0.client-x
      on-touch-end: (event)~>
        current-x = event.changed-touches.0.client-x
        diff = @prev-x - current-x
        switch
        | diff > 100 => @props.next-post!
        | diff < -100 => @props.prev-post!
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
