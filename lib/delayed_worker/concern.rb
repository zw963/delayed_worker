require 'method_source'

class DelayedWorker
  module Concern
    def add_delayed_worker(
      time: Time.now,
      job_name: 'Delayed worker',
      subject_id: respond_to?(:id) ? id : nil,
      subject_type: self.class,
      params: {},
      &block
    )
      callback = block.source.split("\n")[1..-2].join("\n")

      delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mis adding into queue!"

      # valid type: Time, DateTime, ActiveSupport::TimeWithZone or 5.minutes (a integer)
      if (time.respond_to?(:to_time) and time.to_time.is_a?(Time)) or time.is_a?(Integer)
        DelayedWorker.perform_in(time, job_name, subject_id, subject_type, callback, params)
      else
        delayed_worker_log "Delayed worker:\033[0;33m #{job_name} \033[0mtime invalid!"
      end
    end
  end
  ::ActiveRecord::Base.send(:include, Concern)
  ::ActionController::Base.send(:include, Concern)
end
