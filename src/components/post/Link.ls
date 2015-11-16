require! {
  react: {Component, DOM, create-element}
}

class Link extends Component
  render: ->
    DOM.p do
      className: \quote-text
      @props.url

module.exports = Link
