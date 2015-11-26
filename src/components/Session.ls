require! {
  react: {Component, DOM, create-element}
  \lodash.assign : assign
  \./post/Text.ls
  \./post/Photo.ls
  \./post/Quote.ls
  \./post/Link.ls
}

class Session extends Component
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
                  assign do
                    post
                    current-index: @props.session.current-index
                    index-of-posts: i
      else
        ''

module.exports = Session
