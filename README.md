## hubot-superfeedr [![NPM version](https://badge.fury.io/js/hubot-superfeedr.png)](http://badge.fury.io/js/hubot-superfeedr)

A [Hubot](https://github.com/github/hubot) plugin that pushes news from [superfeedr](http://superfeedr.com/)
to a chatroom.

### Usage

    hubot feed add <feed_url> - Adds a subscription to a feed to superfeedr
    hubot feed list - list all subscribed superfeedr feeds
    hubot feed remove <feed_url> - Unsubscribe to a feed

### Installation
1. Edit `package.json` and add `hubot-superfeedr` as a dependency.
2. Add `"hubot-superfeedr"` to your `external-scripts.json` file.
3. `npm install`
4. Create a superfeedr.com account
5. Set the `SUPERFEEDR_LOGIN`, `SUPERFEEDR_PASSWORD` and `HUBOT_SUPERFEEDR_DEFAULT_ROOM` variables
6. Reboot Hubot.

