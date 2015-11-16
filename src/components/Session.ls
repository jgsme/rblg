require! {
  react: {Component, DOM, create-element}
  \lodash.assign : assign
  \./post/Text.ls
  \./post/Photo.ls
  \./post/Quote.ls
  \./post/Link.ls
}

class Session extends Component
  component-did-mount: ->
    document.add-event-listener \keydown, @on-key-down

  on-key-down: (event)~>
    | event.key-code is 74 => @props.next-post!
    | event.key-code is 75 => @props.prev-post!
    | event.key-code is 73 =>
      console.log 'i'
    | event.key-code is 76 =>
      console.log 'l'

  render: ->
    DOM.div do
      style:
        width: \100%
        height: \100%
      className: \session-container
      ref: \container
      if @props.session?
        [
          DOM.div do
            key: \session-counter
            style:
              position: \absolute
              top: 0
              left: 0
              background-color: 'rgba(0, 0, 0, 0.3)'
              color: \#fff
              font-size: \18px
            "#{@props.session.current-index + 1}/#{@props.session.posts.length}"
        ].concat do
          @props.session.posts
            # .slice @props.session.current-index
            .map (post, i)~>
              component =
                switch post.type
                | \text => Text
                | \photo => Photo
                | \quote => Quote
                | \link => Link
              DOM.div do
                key: post.id
                style:
                  width: \100%
                  height: \100%
                  display: if i is @props.session.current-index then \block else \none
                create-element do
                  component
                  post
      else
        ''

module.exports = Session
