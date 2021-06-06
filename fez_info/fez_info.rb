#!/bin/env ruby

require 'discordrb'
require "./fez_info_fetcher"
require 'clockwork'

include Clockwork
@fif = FezInfoFetcher.new
@bot = Discordrb::Bot.new token: 'MjgzODkwMjU0MTYxNjQxNDcz.DGC8Sw.un1zuKlEnSJ04lJGg5NNcpurQq0', client_id: 283890254161641473
@ids = [] #[281756793506627584, 298436402184585220]
DISCORD_MESSAGE_MAX_SIZE = 1500

def send_fezinfo
  infos = @fif.fetch
  infos.each do |info|
    @ids.each do |id|
      begin
        info_detail = info.detail
        title = info.title
        url = info.url

        pos = 0
        max_pos = info_detail.size / DISCORD_MESSAGE_MAX_SIZE + 1
        while max_pos > pos do
          start_pos = DISCORD_MESSAGE_MAX_SIZE*pos
          end_pos = DISCORD_MESSAGE_MAX_SIZE*(pos+1)-1
          message = "#{title}\n詳細: #{url}\n"
          message += "```\n"
          message += "#{info_detail[start_pos..end_pos]}\n"
          message += "page #{pos+1}/#{max_pos}"
          message += "```"

          @bot.send_message(id, message)

          pos = pos + 1
        end
      rescue StandardError => e
        p "[ERROR] can't send messege to id:#{id}"
        p e
        p info.to_s
      end
    end
  end
end

handler do |job|
  self.send(job.to_sym)
end

every(5.minute, 'send_fezinfo')
