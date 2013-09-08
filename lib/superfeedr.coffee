# Description:
#   Realtime displaying of rss feeds
#   Try this for testing: http://push-pub.appspot.com/
#
# Dependencies:
#   superfeedr
#   underscore
#   libicu-dev (optional)
#
# Configuration:
#   SUPERFEEDR_LOGIN
#   SUPERFEEDR_PASSWORD
#   HUBOT_SUPERFEEDR_DEFAULT_ROOM
#
# Commands:
#   hubot feed list
#   hubot feed add <feed_url>
#   hubot feed remove <feed_url>
#
# Author:
#   Leon Bogaert

Superfeedr = require('superfeedr')
_          = require("underscore")

delay = (ms, func) -> setTimeout func, ms

class HubotSuperfeedr
  client: null
  default_room: null
  feeds: null # [] when initialized
  login: null
  password: null
  robot: null

  constructor: (@robot, @login, @password, @default_room) ->

  connect: =>
    try
      @client = new Superfeedr @login, @password
      @client.on 'connected', (@connected)
      @client.on 'notification', (@notification)
    catch eror
      console.log 'Did you use the right login / password?'

  connected: =>
    # Use fat arrow for callbacks: something with scope
    console.log('connected')
    @load_feeds_from_superfeedr()

  notification: (notification) =>
    console.log(notification.feed.title)
    for entry in notification.entries
      # console.log(entry)
      # console.log(entry.link.title)
      # console.log(entry.link.href)
      console.log(entry.link.type)

      room = @default_room
      msg = "#{entry.link.title}: #{entry.link.href}"
      console.log "Going to speek in #{room}"
      console.log "msg: #{msg}"
      @robot.messageRoom room, msg

  subscribe: (feed_url) =>
    @client.subscribe feed_url, (err, feed) ->
      console.log(feed)

  unsubscribe: (feed_url) =>
    @client.unsubscribe feed_url, (err, data) =>

  add_feed: (feed_url) =>
    console.log('add_feed')
    console.log(feed_url)
    console.log(@feeds)

    if not @is_url feed_url
      throw new Error "#{feed_url} is not a valid url. Did you prepend a protocol?"

    if feed_url in @feeds
      throw new Error "#{feed_url} is already being monitored"

    @feeds.push feed_url
    @subscribe feed_url

  remove_feed: (feed_url) =>
    console.log('remove_feed')
    console.log(feed_url)
    @feeds = _.without(@feeds, feed_url)
    @unsubscribe feed_url

  load_feeds_from_superfeedr: =>
    console.log 'load_feeds_from_superfeedr'
    @client.list 1, (err, data) =>
      console.log('ok')
      page = 1
      @parse_feed_callback err, data, page

  parse_feed_callback: (err, data, page) =>
    console.log("page: #{page}")
    console.log("err: #{err}")
    console.log("data: #{data}")

    for feed in data
      @feeds = [] if not @feeds
      @feeds.push feed.url

    # Don't know if this scoping is right??
    if data.length == 20
      page = page + 1
      @client.list page, (err, data) =>
        console.log('ok')
        @parse_feed_callback err, data, page

  is_url: (str) =>
    return str.length < 2083 &&
      str.match(/^(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?/i)

module.exports = (robot) ->
  SUPERFEEDR_LOGIN = process.env.SUPERFEEDR_LOGIN
  SUPERFEEDR_PASSWORD = process.env.SUPERFEEDR_PASSWORD
  SUPERFEEDR_SUBSCRIPTIONS = process.env.SUPERFEEDR_SUBSCRIPTIONS
  HUBOT_SUPERFEEDR_DEFAULT_ROOM = process.env.HUBOT_SUPERFEEDR_DEFAULT_ROOM

  unless SUPERFEEDR_LOGIN
    robot.logger.warning 'The SUPERFEEDR_LOGIN environment variable is not set'

  unless SUPERFEEDR_PASSWORD
    robot.logger.warning 'The SUPERFEEDR_PASSWORD environment variable is not set'

  unless HUBOT_SUPERFEEDR_DEFAULT_ROOM
    robot.logger.warning 'The HUBOT_SUPERFEEDR_DEFAULT_ROOM environment variable is not set'

  if not SUPERFEEDR_LOGIN or not SUPERFEEDR_PASSWORD or not HUBOT_SUPERFEEDR_DEFAULT_ROOM
    return

  hubot_superfeedr = new HubotSuperfeedr(
    robot,
    SUPERFEEDR_LOGIN,
    SUPERFEEDR_PASSWORD,
    HUBOT_SUPERFEEDR_DEFAULT_ROOM
  )
  hubot_superfeedr.connect()

  robot.respond /feed add (.*)$/i, (msg) ->
    feed_url = msg.match[1].trim()
    try
      hubot_superfeedr.add_feed(feed_url)
    catch error
      msg.send error
      return

    msg.send "Added #{feed_url} to feeds"

  robot.respond /feed remove (.*)$/i, (msg) ->
    feed_url = msg.match[1].trim()
    hubot_superfeedr.remove_feed feed_url
    msg.send "Removed #{feed_url} from feeds"

  robot.respond /feed list$/i, (msg) ->
    if not hubot_superfeedr.feeds
      msg.send "Still looking up subscriptions: wait a moment"
    else
      response = hubot_superfeedr.feeds.join "\n"
      msg.send response
