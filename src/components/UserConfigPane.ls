require! {
  react: {Component, DOM}
  \react-dom : {findDOMNode}
}

class UserConfigPane extends Component
  on-change: (key, event)~~> @props.update-config key, event.target.value

  render: ->
    DOM.div do
      className: \user-config-container
      DOM.ul do
        className: \user-config-list
        DOM.li do
          key: \tumblr-consumer-key
          DOM.label do
            htmlFor: \tumblr-consumer-key
            'Tumblr consumer key:'
          DOM.input do
            type: \text
            id: \tumblr-consumer-key
            value: @props.config.tumblr_consumer_key
            on-change: @on-change \tumblr_consumer_key
        DOM.li do
          key: \tumblr-consumer-secret
          DOM.label do
            htmlFor: \tumblr-consumer-secret
            'Tumblr consumer secret:'
          DOM.input do
            type: \password
            id: \tumblr-consumer-secret
            value: @props.config.tumblr_consumer_secret
            on-change: @on-change \tumblr_consumer_secret
        DOM.li do
          key: \tumblr-token
          DOM.label do
            htmlFor: \tumblr-token
            'Tumblr token:'
          DOM.input do
            type: \text
            id: \tumblr-token
            value: @props.config.tumblr_token
            on-change: @on-change \tumblr_token
        DOM.li do
          key: \tumblr-token-secret
          DOM.label do
            htmlFor: \tumblr-token-secret
            'Tumblr token secret:'
          DOM.input do
            type: \password
            id: \tumblr-token-secret
            value: @props.config.tumblr_token_secret
            on-change: @on-change \tumblr_token_secret
      DOM.button do
        on-click: @props.save-config
        \save

module.exports = UserConfigPane
