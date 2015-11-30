require! {
  react: {Component, DOM, create-element}
}

class Sessions extends Component
  render: ->
    DOM.div do
      className: \sessions-container
      DOM.ul do
        className: \sessions-container-ul
        @props.sessions.map (session, i)~>
          DOM.li do
            key: "session-#{i}"
            DOM.p do
              className: \session
              new Date session.created-at .toString!
            DOM.button do
              on-click: @props.attach-session session.id
              \attach
            DOM.button do
              on-click: @props.delete-session session.id
              \delete
      DOM.button do
        className: \new-session
        on-click: @props.new-session
        'New session'

module.exports = Sessions
