require! {
  react: {Component, DOM, create-element}
  \sanitize-html : sanitize
}

class Quote extends Component
  render: ->
    DOM.div do
      style:
        background-color: \#fff
        width: \80%
        margin: '0 auto'
        padding: '30px 5px'
      DOM.q do
        dangerouslySetInnerHTML:
          __html: sanitize @props.text
      DOM.p do
        dangerouslySetInnerHTML:
          __html: sanitize @props.source

module.exports = Quote
