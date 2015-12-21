require! {
  react: {Component, DOM, create-element}
}

class Photo extends Component
  render: ->
    DOM.div do
      style:
        width: \100%
      @props.photos.map (photo)~>
        DOM.div do
          key: photo.original_size.url
          style:
            width: \100%
            height: "#{window.innerHeight}px"
            background-size: \contain
            background-image: "url(#{photo.original_size.url})"
            background-position: \center
            background-repeat: \no-repeat
          if @props.index-of-posts >= @props.current-index # for cache
            DOM.img do
              src: photo.original_size.url
              style:
                width: \1px
                height: \1px
                position: \absolute
                left: \-5px
                top: \-5px
          else ''

module.exports = Photo
