require! {
  react: {Component, DOM, create-element}
}

class Sessions extends Component
  render: ->
    DOM.div do
      className: \sessions-container
      DOM.ul do
        style:
          margin: 0
          padding: 0
        @props.sessions.map (session, i)~>
          created-at = new Date session.created-at
          DOM.li do
            key: "session-#{session.id}"
            style:
              background-color: \#4747EB
              list-style-type: \none
              margin-bottom: \5px
            DOM.input do
              style:
                margin-bottom: \-10px
                padding: 0
                font-size: \24px
                color: \#fff
                background-color: 'rgba(0, 0, 0, 0)'
                border: 0
              on-key-down: @props.rename-session session.id
              default-value: session.name
            DOM.p do
              style:
                margin: 0
                padding: 0
                font-size: \12px
                color: \#fff
              "#{created-at.getFullYear!}/#{created-at.getMonth! + 1}/#{created-at.getDate!} #{created-at.getHours!}:#{created-at.getMinutes!}"
            DOM.button do
              className: 'pure-button'
              style:
                width: \60%
                background-color: \#1CB841
                color: \#fff
                font-size: \24px
                padding: \5px
              on-click: @props.attach-session session.id
              DOM.i do
                className: 'fa fa-link'
                style:
                  margin-right: \5px
                  font-size: \24px
              \Attach
            DOM.button do
              className: 'pure-button'
              style:
                position: \absolute
                right: 0
                background-color: \#CA3C3C
                color: \#fff
              on-click: @props.delete-session session.id
              DOM.i do
                className: 'fa fa-trash-o'
      DOM.button do
        className: 'pure-button pure-button-primary'
        style:
          width: \100%
          font-size: \24px
          margin-top: \20px
        on-click: @props.new-session
        DOM.i do
          className: 'fa fa-plus-square-o'
          style:
            margin-right: \5px
        'New session'

module.exports = Sessions
