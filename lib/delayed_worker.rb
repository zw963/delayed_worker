require 'delayed_worker/delayed_worker'
require 'delayed_worker/add_delayed_worker'
require 'delayed_worker/version'

def delayed_worker_log(msg)
  if defined? Rails and Rails.respond_to?(:logger)
    Rails.logger.info msg
  else
    $stderr.puts msg
  end
end
