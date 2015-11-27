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
}

firebase =
  fs.readFileSync \.firebase.json
    .toString!
    |> JSON.parse

tumblr-handler = (type, user, opt, callback)->
  client = tumblr.create-client user.config_tumblr
  cb = (err, res)->
    if err?
      callback err
    else
      callback null, if type is \dashboard then res.posts else res
  inf-cb = (user, opt, weight, err, res)-->
    filtered-posts = res.posts.filter (post)-> post.id < last-id
    switch filtered-posts.length
    | 20 =>
      opt.since_id = filtered-posts.0.id
      if opt.cache?
        opt.cache = opt.cache.concat filtered-posts
        opt.cache = uniq opt.cache, \id
      else
        opt.cache = filtered-posts
      tumblr-handler \dashboard, user, opt, callback
    | 0 =>
      if opt.cache?
        return callback null, opt.cache
      opt.weight = weight - 1
      tumblr-handler \dashboard, user, opt, callback
    | otherwise =>
      r =
        if opt.cache?
          uniq do
            opt.cache.concat filtered-posts
            \id
        else filtered-posts
      callback null, r
  args = []
  switch type
  | \dashboard =>
    if opt.since_id?
      console.log opt.since_id
      args = [{since_id: opt.since_id}, inf-cb user, opt, opt.weight]
    else if opt.last-id? and opt.first-id?
      {last-id, first-id, length, weight} = opt
      if weight is undefined then weight = 20
      estimate-id = last-id - Math.round(((first-id - last-id) / length) * weight)
      console.log estimate-id
      args = [{since_id: estimate-id}, inf-cb user, opt, weight]
    else
      args = [opt, cb]
  | \reblog => args = [user.config_tumblr.base_hostname, opt, cb]
  | \like => args = [opt.id, opt.reblog_key, cb]
  | otherwise => return callback new Error 'Not supported method'
  client[type].apply client, args

api-handler = (req, rep)->
  err, res, json <- request "#{firebase.url}/users/#{req.query.uid}.json?auth=#{req.query.token}"
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
