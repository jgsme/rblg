require! {
  react: {Component, DOM, create-element}
  \lodash.assign : assign
  \./Posts.ls
}

class Session extends Component
  component-did-mount: ->
    @refs.container.add-event-listener \click, (event)~>
      {x} = event
      w = window.inner-width
      d = w *  0.3
      switch
      | x > w - d => @props.next-post!
      | x < d => @props.prev-post!

  render: ->
    DOM.div do
      style:
        width: \100%
      ref: \container
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
      create-element do
        Posts
        session: @props.session

module.exports = Session
