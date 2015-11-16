require! {
  react: {Component, DOM, create-element}
}

class Text extends Component
  render: ->
    DOM.p do
      className: \text-title
      @props.title

module.exports = Text
