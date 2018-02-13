require 'sidekiq'

class DelayedWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true, queue: 'default'

  def perform(job_name, subject_id, subject_type, callback, params)
    type = Object.const_get(subject_type)
    if type < ActiveRecord::Base
      record = type.find(subject_id)
      delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis start!"
      record.instance_eval(callback, __FILE__, __LINE__)
    else
      delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis start!"
      instance_eval(callback, __FILE__, __LINE__)
    end

    delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis finished!"
  end
end
