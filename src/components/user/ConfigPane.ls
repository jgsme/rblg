require! {
  react: {Component, DOM}
}

class UserConfigPane extends Component
  on-change: (key, event)~~> @props.update-config-tumblr key, event.target.value

  render: ->
    DOM.div do
      style:
        display: if @props.user is null then \none else \block
        width: \80%
        min-width: \320px
        background-color: \#fff
        margin: '0 auto'
      DOM.div do
        className: 'pure-form pure-form-aligned'
        DOM.div do
          className: 'pure-control-group'
          DOM.label do
            htmlFor: \tumblr-consumer-key
            'Tumblr consumer key:'
          DOM.input do
            type: \password
            id: \tumblr-consumer-key
            value: @props.config-tumblr.consumer_key
            on-change: @on-change \consumer_key
        DOM.div do
          className: 'pure-control-group'
          DOM.label do
            htmlFor: \tumblr-consumer-secret
            'Tumblr consumer secret:'
          DOM.input do
            type: \password
            id: \tumblr-consumer-secret
            value: @props.config-tumblr.consumer_secret
            on-change: @on-change \consumer_secret
        DOM.div do
          className: 'pure-control-group'
          DOM.label do
            htmlFor: \tumblr-token
            'Tumblr token:'
          DOM.input do
            type: \password
            id: \tumblr-token
            value: @props.config-tumblr.token
            on-change: @on-change \token
        DOM.div do
          className: 'pure-control-group'
          DOM.label do
            htmlFor: \tumblr-token-secret
            'Tumblr token secret:'
          DOM.input do
            type: \password
            id: \tumblr-token-secret
            value: @props.config-tumblr.token_secret
            on-change: @on-change \token_secret
        DOM.div do
          className: 'pure-control-group'
          DOM.label do
            htmlFor: \tumblr-base-hostname
            'Tumblr base hostname:'
          DOM.input do
            type: \text
            id: \tumblr-base-hostname
            value: @props.config-tumblr.base_hostname
            on-change: @on-change \base_hostname
        DOM.button do
          className: 'pure-button pure-button-primary'
          style:
            width: \100%
            font-size: \18px
          on-click: @props.save-config-tumblr
          \save

module.exports = UserConfigPane
