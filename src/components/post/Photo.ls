require! {
  react: {Component, DOM, create-element}
}

class Photo extends Component
  render: ->
    DOM.div do
      style:
        width: \100%
        height: \100%
        background-size: \contain
        background-image: "url(#{@props.photos.0.original_size.url})"
        background-position: \center
        background-repeat: \no-repeat
      if @props.index-of-posts >= @props.current-index # for cache
        DOM.img do
          src: @props.photos.0.original_size.url
          style:
            width: \1px
            height: \1px
            position: \absolute
            left: \-5px
            top: \-5px
      else ''

module.exports = Photo
