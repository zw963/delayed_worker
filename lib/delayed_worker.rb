require 'delayed_worker/workers/delayed_worker'
require 'delayed_worker/concern'
require 'delayed_worker/version'

def delayed_worker_log(msg)
  if defined? Rails and Rails.respond_to?(:logger)
    Rails.logger.info msg
  else
    $stderr.puts msg
  end
end
