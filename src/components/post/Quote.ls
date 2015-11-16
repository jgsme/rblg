require! {
  react: {Component, DOM, create-element}
  \sanitize-html : sanitize
}

class Quote extends Component
  render: ->
    DOM.q do
      className: \quote-text
      dangerouslySetInnerHTML:
        __html: sanitize @props.text

module.exports = Quote
