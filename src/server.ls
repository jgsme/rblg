require! {
  fs
  hapi: Hapi
  good: Good
  \good-console : good-console
  vision: Vision
  jade
  inert: Inert
  request
  \tumblr.js : tumblr
}

firebase =
  fs.readFileSync \.firebase.json
    .toString!
    |> JSON.parse

server = new Hapi.Server!
  ..connection do
      port: process.env.npm_package_config_PORT or 3000
  ..register do
      [
        * register: Good
          options:
            reporters: [
              * reporter: good-console
                events: do
                  response: \*
                  log: \*
            ]
        * Vision
        * Inert
      ]
      (err)->
        if err? then throw err
        server
          ..views do
              engines:
                jade: jade
              path: __dirname
              compile-options:
                pretty: true
          ..route do
              method: \GET
              path: \/
              handler: (req, rep)->
                rep.view do
                  \index
                  firebase-url: firebase.url
          ..route do
              method: \GET
              path: '/assets/{param*}'
              handler:
                directory:
                  path: \./build
          ..route do
              method: \GET
              path: '/api/{type}'
              handler: (req, rep)->
                err, res, json <- request "#{firebase.url}/users/#{req.query.uid}.json?auth=#{req.query.token}"
                if err?
                  return rep do
                          status: \error
                          message: err
                user = JSON.parse json
                switch
                | user.error? =>
                  rep do
                    status: \error
                    message: user.error
                | otherwise =>
                  client = tumblr.create-client user.config_tumblr
                  opt =
                    | req.query.opt? => JSON.parse req.query.opt
                    | otherwise => {}
                  callback = (err, res)->
                    if err?
                      return rep do
                              status: \error
                              message: err
                    rep do
                      status: \ok
                      data: res
                  args = []
                  switch req.params.type
                  | \dashboard => args = [opt, callback]
                  | \reblog => args = [user.config_tumblr.base_hostname, opt, callback]
                  | otherwise =>
                    return rep do
                            status: \error
                            message: 'Not supported method'
                  client[req.params.type].apply client, args
          ..start ->
              server.log \info, "server running: #{server.info.uri}"
