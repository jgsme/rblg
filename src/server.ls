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
  \lodash.uniq : uniq
  \neo-async : async
}

firebase =
  fs.readFileSync \.firebase.json
    .toString!
    |> JSON.parse

Fire = ({uid, token})->
  user-root = "#{firebase.url}/users/#{uid}"
  _get = (path, callback)->
    request "#{path}.json?auth=#{token}", callback
  _patch = (path, body, callback)->
    request do
      method: \PATCH
      url: "#{path}.json?auth=#{token}"
      json: true
      body: body
      callback

  user: (callback)-> _get user-root, callback
  set-metadata: (key, body, callback)-> _patch "#{user-root}/sessions/#{key}", body, callback

tumblr-handler = (type, user, opt, callback)->
  client = tumblr.create-client user.config_tumblr
  cb = (err, res)->
    if err?
      callback err
    else
      callback null, res

  args = []
  switch type
  | \dashboard => args = [opt, cb]
  | \reblog => args = [user.config_tumblr.base_hostname, opt, cb]
  | \like => args = [opt.id, opt.reblog_key, cb]
  | otherwise => return callback new Error 'Not supported method'
  client[type].apply client, args

api-handler = (req, rep)->
  fire =
    Fire do
      uid: req.query.uid
      token: req.query.token
  err, res, json <- fire.user
  if err?
    return
      rep do
        status: \error
        message: err
  user = JSON.parse json
  switch
  | user.error? =>
    rep do
      status: \error
      message: user.error
  | otherwise =>
    opt =
      | req.query.opt? => JSON.parse req.query.opt
      | otherwise => {}
    switch
    | opt.is-init =>
      err, res <- async.map-limit do
        [0 til 12]
        4
        (n, cb)-> tumblr-handler \dashboard, user, {offset: n * 20}, cb
      posts =
        res.reduce do
          (prev, current)-> prev.concat current.posts
          []
      if err?
        return
          rep do
            status: \error
            message: err
      err, res, json <- fire.set-metadata do
                          opt.key
                          created-at: user.sessions[opt.key].created-at
                          first-id: posts.0.id
                          last-id: posts[*-1].id
                          length: posts.length
      if err?
        return
          rep do
            status: \error
            message: err
      rep do
        status: \ok
        data: posts
    | opt.is-inf =>
      {key} = opt
      session = user.sessions[key]
      weight = 20
      {last-id, first-id, length} = session
      calc = (w)-> last-id - Math.round(((first-id - last-id) / length) * w)
      fn = (memo, opt)->
        err, res <- tumblr-handler \dashboard, user, opt
        filtered-posts = res.posts.filter (post)-> post.id < last-id
        switch filtered-posts.length
        | 20 =>
          opt.since_id = filtered-posts.0.id
          next-memo = memo.concat filtered-posts
          next-memo = uniq memo, \id
          fn next-memo, opt
        | 0 =>
          if memo.length > 0
            return callback null, memo
          weight -= 1
          opt.since_id = calc weight
          fn memo, opt
        | otherwise =>
          posts =
            if memo.length > 0
              uniq do
                memo.concat filtered-posts
                \id
            else
              filtered-posts
          session.last-id = posts[*-1].id
          session.length += posts.length
          err, res, json <- fire.set-metadata key, session
          if err?
            rep do
              status: \error
              message: err
          else
            rep do
              status: \ok
              data: posts
      fn do
        []
        since_id: calc weight
    | otherwise =>
      err, res <- tumblr-handler req.params.type, user, opt
      if err?
        rep do
          status: \error
          message: err
      else
        rep do
          status: \ok
          data: res

main = (err)->
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
        handler: api-handler
    ..start ->
        server.log \info, "server running: #{server.info.uri}"

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
      main
