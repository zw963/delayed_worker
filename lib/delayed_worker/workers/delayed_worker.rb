require 'sidekiq'

class DelayedWorker
  include Sidekiq::Worker

  def perform(job_name, subject_id, subject_type, callback, params, scheduled_at)
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
      logger.info "#{job_name} was start!"

      # If is a scheduled job, but time not match, do noop
      if scheduled_at and record.has_attribute?(:delayed_worker_scheduled_at) and record.delayed_worker_scheduled_at.to_i != scheduled_at.to_i
        logger.warn "#{job_name} schedule time is not matched, noop ..."
        return
      end

      if scheduled_at and record.has_attribute?(:delayed_worker_disabled) and record.disabled
        # If is a delayed job, when close this job, do noop
        logger.warn "#{job_name} job is disabled, noop ..."
        return
      end

      # Otherwise, run task
      record.instance_eval(callback, __FILE__, __LINE__)
    else
      logger.info "#{job_name} was start!"
      instance_eval(callback, __FILE__, __LINE__)
    end

    logger.info "#{job_name} was finished!"
  end
end
