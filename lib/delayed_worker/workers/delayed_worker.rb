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
      logger.info "Delayed worker: #{job_name} is start!"
      record.instance_eval(callback, __FILE__, __LINE__)
    else
      logger.info "Delayed worker: #{job_name} is start!"
      instance_eval(callback, __FILE__, __LINE__)
    end

    logger.info "Delayed worker: #{job_name} is finished!"
  end
end
