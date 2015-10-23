require! {
  hapi: Hapi
  good: Good
}

server = new Hapi.Server!
                ..connection do
                    port: process.env.PORT or 3000

server
  ..route do
      method: \GET
      path: \/
      handler: (req, rep)-> rep \hello
  ..register do
      register: Good
      options:
        reporters: [
          * reporter: require \good-console
            events: do
              response: \*
              log: \*
        ]
      (err)->
        if err? then throw err
        server.start -> server.log \info, "server running: #{server.info.uri}"
