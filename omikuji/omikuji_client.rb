#!/usr/bin/env ruby

require 'discordrb'
require 'faraday'
require 'json'
bot = Discordrb::Bot.new token: 'ODUwOTYxMDEzODU5ODExMzY5.YLxVMw.I0h4UFIF07TIVgfj09f8hOr-eUo', client_id: 850961013859811369

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
