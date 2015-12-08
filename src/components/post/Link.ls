require! {
  react: {Component, DOM, create-element}
}

class Link extends Component
  render: ->
    DOM.div do
      style:
        background-color: \#fff
        width: \80%
        margin: '0 auto'
        padding: '30px 5px'
      DOM.a do
        href: @props.url
        target: \_blank
        DOM.p do
          color: \#000
          @props.title

module.exports = Link
