#!/usr/bin/env ruby

require 'discordrb'
require 'faraday'
require 'json'
bot = Discordrb::Bot.new token: ENV['DISCORD_TOKEN'], client_id: ENV['DISCORD_ID']
api_host = ENV.fetch('API_HOST', 'http://localhost')

def user_name(event)
  au = event.author
  au.nick || au.name
end

bot.message(with_text: /(占い)|(uranai\d*)|(うらない)|(omikuji)|(おみくじ)/) do |event|
  user_id = event.author.id
  con = Faraday.new(api_host, ssl: { verify: false })
  res = con.get("/api/omikujis/random/#{user_id}")
  body = JSON.parse(res.body)
  omikuji = body['name']
  event.respond "#{user_name(event)} は 【#{omikuji}】 です!"
end

bot.message do |event|
  con = Faraday.new(api_host, ssl: { verify: false })
  res = con.get('/api/custom_responses/words', {word: event.content})
  words = JSON.parse(res.body.force_encoding('utf-8'))['words']
  words.each do |w|
    event.respond w
  end
end

bot.run
