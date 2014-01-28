# Description:
#   Grumpy Cat does not approve.
#
# Commands:
#   hubot grumpy

module.exports = (robot) ->
  robot.respond /grumpy$/i, (msg) ->
    imageMe msg, (url) ->
      msg.send url

imageMe = (msg, cb) ->
  query = "grumpy cat"
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  # console.log q
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image  = msg.random images
        cb "#{image.unescapedUrl}#.png"

