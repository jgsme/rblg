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
          DOM.li do
            key: "session-#{i}"
            style:
              background-color: \#4747EB
              list-style-type: \none
              margin-bottom: \5px
            DOM.p do
              style:
                margin: 0
                padding: 0
                font-size: \24px
                color: \#fff
              new Date session.created-at .toString!
            DOM.button do
              className: 'pure-button'
              style:
                width: \60%
                background-color: \#1CB841
                color: \#fff
                font-size: \18px
              on-click: @props.attach-session session.id
              DOM.i do
                className: 'fa fa-link'
                style:
                  margin-right: \5px
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
