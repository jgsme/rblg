require! {
  react: {Component, DOM, create-element}
}

class Sessions extends Component
  component-did-mount: -> @props.update-sessions!

  render: ->
    DOM.div do
      className: \sessions-container
      DOM.ul do
        className: \sessions-container-ul
        @props.sessions.map (session, i)~>
          DOM.li do
            key: "session-#{i}"
            on-click: @props.attach-session session._id
            new Date session.created-at .toString!
      DOM.button do
        className: \new-session
        on-click: @props.new-session
        'New session'

module.exports = Sessions
