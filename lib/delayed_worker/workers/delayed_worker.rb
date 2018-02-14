require 'sidekiq'

class DelayedWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true, queue: 'default'

  def perform(job_name, subject_id, subject_type, callback, params)
    _type = Object.const_get(subject_type)
    _params = Hash.new do |hash, key|
      if hash.key? key.to_s and not hash[key.to_s].nil?
        hash[key.to_s]
      else
        nil
      end
    end

    _params = _params.merge(params)
    params = _params

    if defined? ::ActiveRecord::Base and _type < ::ActiveRecord::Base
      record = _type.find(subject_id)
      delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis start!"
      record.instance_eval(callback, __FILE__, __LINE__)
    else
      delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis start!"
      instance_eval(callback, __FILE__, __LINE__)
    end

    delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis finished!"
  end
end
