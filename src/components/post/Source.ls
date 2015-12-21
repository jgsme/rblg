require! {
  react: {Component, DOM, create-element}
}

class Source extends Component
  anchor: (el)->
    DOM.a do
      href: @props.source_url
      target: \_blank
      el

  title: ->
    DOM.p do
      style:
        font-size: \18px
        padding: \5px
      @props.source_title

  title-with-source: -> @anchor @title!
  just-source: -> @anchor @props.source_url

  render: ->
    DOM.div do
      style:
        position: \relative
        background-color: \#fff
        width: \80%
        margin: '0 auto'
        margin-bottom: \20px
        display: if @props.source_url? is false and @props.source_title? is false then \none else \block
      switch
      | @props.source_url? and @props.source_title? => @title-with-source!
      | @props.source_title? => @title!
      | @props.source_url? => @just-source!
      | otherwise => ''

module.exports = Source
