require! {
  \lodash.assign : assign
}

exports.dashboard-handler = (post)->
  switch post.type
  | \text, \photo, \quote, \link =>
    assign do
      type: post.type
      _id: "post-#{post.id}"
      id_raw: post.id
      reblog_key: post.reblog_key
      blog_name: post.blog_name
      liked: post.liked
      source_url: post.source_url
      source_title: post.source_title
      post_url: post.post_url
      switch post.type
      | \text =>
        title: post.title
        body: post.body
      | \photo =>
        photos: post.photos
        caption: post.caption
        is-photoset: post.photos.length > 1
      | \quote =>
        text: post.text
        source: post.source
      | \link =>
        title: post.title
        url: post.url
  | otherwise => null

exports.dupulicate-resolver = (list, target)->
  target.filter (post)->
    list.reduce do
      (p, c)-> if c._id is post._id then false else true
      true
