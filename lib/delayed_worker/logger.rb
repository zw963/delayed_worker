require 'fileutils'

class DelayedWorker
  module Logger
    module_function

    def logger
      if @logger.nil?
        if defined? ::Rails and ::Rails.respond_to?(:root)
          @logger = ::Logger.new "#{::Rails.root}/log/delayed_worker.log", 'weekly'
        else
          FileUtils.mkdir_p('log')
          @logger ||= ::Logger.new 'log/delayed_worker.log', 'weekly'
        end
        @logger.progname = 'Delayed Worker'
      end
      @logger
    end
  end
  include Logger
end
