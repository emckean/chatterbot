require 'logger'

module Chatterbot
  module Logging

    def logger
      # log to the dest specified in the config file, rollover after 10mb of data
      @@_logger ||= Logger.new(log_dest, 0, 1024 * 1024)
    end

    def debug(s)
      logger.debug s unless ! logging?
    end

    def critical(s)
      puts s
      debug s
    end
    
    def log(txt, source=nil)
      # create a dataset from the items table

      return unless log_tweets?

      tweets = db[:tweets]

      data = {:txt => txt, :bot => botname, :created_at => 'NOW()'.lit}
      if source != nil
        data = data.merge(:user => source['from_user'],
                          :source_id => source['id'],
                          :source_tweet => source['text'])
      end

      # populate the table
      tweets.insert(data)
    end

  end
end