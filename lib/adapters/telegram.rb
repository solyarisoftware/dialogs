require 'telegram/bot'

module ClientAdapter
  #
  # Telegram Bot API adapter
  #
  module Telegram
    
    def self.create
      @token = 'INSERT_HERE_YOUR_REAL_BOT_TOKEN'
      @client = Telegram::Bot::Client.new(@token)
    end

    def self.read
      # TODO
      # instantiate a client update object 
      update = Telegram::Bot::Types::Update.new(data)

      update_id = update.update_id
      message = update.message
      message_id = message.message_id 
      chat_id = message.chat.id
    
      message.text
    end

    def self.write(value)
      # TODO
      @client.api.send_message(chat_id: chat_id, text: value)
    end
  end

end
