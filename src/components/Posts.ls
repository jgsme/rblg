require! {
  react: {Component, DOM, create-element}
  \lodash.assign : assign
  \./post/Text.ls
  \./post/Photo.ls
  \./post/Quote.ls
  \./post/Link.ls
}

class Posts extends Component
  render: ->
    DOM.div do
      style:
        width: \100%
        height: \100%
      @props
        .session
        .posts
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

module.exports = Posts
