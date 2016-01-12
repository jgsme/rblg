require! {
  react: {Component, DOM, create-element}
  \lodash.assign : assign
  \./post/Text.ls
  \./post/Photo.ls
  \./post/Quote.ls
  \./post/Link.ls
  \./post/Source.ls
}

class Posts extends Component
  render: ->
    begin = @props.session.current-index - 200
    end = @props.session.current-index + 200
    if begin < 0 then begin = 0
    DOM.div do
      style:
        width: \100%
      @props
        .session
        .posts
        .map (post, i)->
          post.index = i
          post
        .slice begin, end
        .map (post)~>
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
              display: if post.index is @props.session.current-index then \block else \none
            create-element do
              component
              assign do
                post
                current-index: @props.session.current-index
            create-element do
              Source
              post

module.exports = Posts
