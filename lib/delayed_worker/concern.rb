require 'method_source'

class DelayedWorker
  module Concern
    def add_job_into_delayed_worker(
      scheduled_at: nil,
      job_name: 'Delayed worker',
      subject_id: respond_to?(:id) ? id : nil,
      subject_type: self.class,
      params: {},
      queue: 'default',
      backtrace: false,
      retry: 12,
      &block
    )

      callback = block.source.split("\n")[1..-2].join("\n")

      delayed_worker = DelayedWorker.set(queue: queue, backtrace: backtrace, retry: binding.local_variable_get(:retry))

      Logger.logger.info "#{job_name} is adding into queue #{queue}!"

      if scheduled_at.nil?
        # last arg pass in scheduled_at as nil, this means no delayed.
        delayed_worker.perform_async(job_name, subject_id, subject_type, callback, params, nil)
        # valid type: Time, DateTime, ActiveSupport::TimeWithZone or 5.minutes (a integer)
      elsif scheduled_at.respond_to?(:to_time) && scheduled_at.to_time.is_a?(Time) || scheduled_at.is_a?(Integer)
        delayed_worker.perform_in(scheduled_at, job_name, subject_id, subject_type, callback, params, scheduled_at.to_i)
      else
        Logger.logger.error "#{job_name} time invalid!"
      end
    end
    alias add_job_to_delayed_worker add_job_into_delayed_worker
  end

  ::ActiveRecord::Base.send(:include, Concern) if defined? ::ActiveRecord::Base
  ::ActionController::Base.send(:include, Concern) if defined? ::ActionController::Base
end
