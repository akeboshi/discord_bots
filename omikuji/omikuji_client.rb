#!/usr/bin/env ruby

require 'discordrb'
require 'faraday'
require 'json'
bot = Discordrb::Bot.new token: ENV['DISCORD_TOKEN'], client_id: ENV['DISCORD_ID']

def user_name(event)
  au = event.author
  au.nick || au.name
end

bot.message(with_text: /(占い)|(uranai\d*)|(うらない)|(omikuji)|(おみくじ)/) do |event|
  user_id = event.author.id
  con = Faraday.new("https://omikuji.akeboshi.dev", ssl: { verify: false })
  res = con.get("/api/omikujis/random/#{user_id}")
  body = JSON.parse(res.body)
  omikuji = body['name']
  event.respond "#{user_name(event)} は 【#{omikuji}】 です!"
end

bot.run
