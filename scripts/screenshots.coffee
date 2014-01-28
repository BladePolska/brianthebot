# Description:
#   Screenshot this website under a chosen browser.
#
# Commands:
#   brian screenshot me <url> under <browser_dict> - Self explanatory.
#
# Browser dict example:
#   {"os": "Windows", "os_version": "7", "browser_version": "8.0", "browser": "ie"}

api_url    = 'http://www.browserstack.com/screenshots'
username   = process.env.HUBOT_BROWSERSTACK_USERNAME
api_key    = process.env.HUBOT_BROWSERSTACK_API_KEY

brian_host = process.env.HEROKU_URL

module.exports = (robot) ->
  robot.router.post '/brian/screenshot/:room', (req, res) ->
    room = req.params.room

    console.log "SCREENSHOTS: got #{req}, #{res}"

    data = JSON.parse res.body.payload
    console.log "SCREENSHOTS: parsed to: #{data}"

    screenshots = data.screenshots ? []

    for screenshot in screenshots
      screenshot_url = screenshot.image_url

      if screenshot_url
        robot.messageRoom room, "#{screenshot.url} in #{screenshot.browser} #{screenshot.browser_version} running under #{screenshot.os} #{screenshot.os_version}: \n#{screenshot_url}"

  robot.respond /screenshot( me)? (.*?) under (.*)/i, (msg) ->
    try
      browser_dict = JSON.parse msg.match[3]
    catch
      msg.send "'#{msg.match[3]}' must be a valid JS dictionary, '{\"os\": \"Windows\", \"os_version\": \"7\", \"browser_version\": \"8.0\", \"browser\": \"ie\"}' is a great example."
      return

    screenshotMe msg, msg.match[2], browser_dict, () ->
      msg.send "Fetching the screenshots (it will take a while, be patient!)..."

screenshotMe = (msg, url, browser_dict, cb) ->
  room = msg[0]
  callback_url = "#{brian_host}/brian/screenshot/#{room}"

  q = browsers: [browser_dict], url: url, callback_url:callback_url
  msg.http(api_url)
    .auth(username, api_key)
    .post(QS.stringify(q)) (err, res, body) ->
      console.log res, body
      cb()
