require! {
  react: {Component, DOM, create-element}
  \react-redux : {connect}
  \../actions.ls
  \./User.ls
}

class Rblg extends Component
  component-will-mount: -> @props.dispatch actions.initialize!

  render: ->
    DOM.div do
      className: \container
      create-element do
        User
        user: @props.user
        config: @props.config
        check-auth: ~> @props.dispatch actions.check-auth!
        auth: ~> @props.dispatch actions.auth!
        unauth: ~> @props.dispatch actions.unauth!
        update-config: (key, value)~> @props.dispatch actions.update-config key, value
        save-config: ~>  @props.dispatch actions.save-config!

module.exports =
  connect do
    (state)-> state
  <| Rblg
