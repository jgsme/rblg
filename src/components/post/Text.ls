require! {
  react: {Component, DOM, create-element}
  \sanitize-html : sanitize
}

class Text extends Component
  render: ->
    DOM.div do
      style:
        background-color: \#fff
        width: \80%
        margin: '0 auto'
        padding: \5px
      DOM.p do
        style:
          font-size: \26px
          margin-bottom: \5px
        @props.title
      DOM.p do
        style:
          color: \#000
        dangerouslySetInnerHTML:
          __html: sanitize @props.body

module.exports = Text
