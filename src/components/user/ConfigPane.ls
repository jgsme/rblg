require! {
  react: {Component, DOM}
}

class UserConfigPane extends Component
  on-change: (key, event)~~> @props.update-config-tumblr key, event.target.value

  render: ->
    DOM.div do
      className: \user-config-container
      style:
        display: if @props.user is null then \none else \block
      DOM.ul do
        className: \user-config-list
        DOM.li do
          key: \tumblr-consumer-key
          DOM.label do
            htmlFor: \tumblr-consumer-key
            'Tumblr consumer key:'
          DOM.input do
            type: \password
            id: \tumblr-consumer-key
            value: @props.config-tumblr.consumer_key
            on-change: @on-change \consumer_key
        DOM.li do
          key: \tumblr-consumer-secret
          DOM.label do
            htmlFor: \tumblr-consumer-secret
            'Tumblr consumer secret:'
          DOM.input do
            type: \password
            id: \tumblr-consumer-secret
            value: @props.config-tumblr.consumer_secret
            on-change: @on-change \consumer_secret
        DOM.li do
          key: \tumblr-token
          DOM.label do
            htmlFor: \tumblr-token
            'Tumblr token:'
          DOM.input do
            type: \password
            id: \tumblr-token
            value: @props.config-tumblr.token
            on-change: @on-change \token
        DOM.li do
          key: \tumblr-token-secret
          DOM.label do
            htmlFor: \tumblr-token-secret
            'Tumblr token secret:'
          DOM.input do
            type: \password
            id: \tumblr-token-secret
            value: @props.config-tumblr.token_secret
            on-change: @on-change \token_secret
        DOM.li do
          key: \tumblr-base-hostname
          DOM.label do
            htmlFor: \tumblr-base-hostname
            'Tumblr base hostname:'
          DOM.input do
            type: \text
            id: \tumblr-base-hostname
            value: @props.config-tumblr.base_hostname
            on-change: @on-change \base_hostname
      DOM.button do
        on-click: @props.save-config-tumblr
        \save

module.exports = UserConfigPane
