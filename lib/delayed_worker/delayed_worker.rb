require 'sidekiq'

class DelayedWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true, queue: 'default'

  def perform(job_name, ar_id, ar_type, callback, params)
    delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis start!"

    type = Object.const_get(ar_type)
    if type < ActiveRecord::Base
      record = type.find(ar_id)
      record.instance_eval(callback, __FILE__, __LINE__)
    else
      instance_eval(callback, __FILE__, __LINE__)
    end

    delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis finished!"
  end
end
