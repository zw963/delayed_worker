# -*- coding: utf-8 -*-

require 'delayed_worker/version'

class DelayedWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true, queue: 'promotion'

  def perform(ar_id, ar_type, callback, params)
    logger.info("\033[0;33m开始执行后台任务!\033[0m")
    type = ar_type.constantize
    if type < ActiveRecord::Base
      ar_object = type.find(ar_id)
      ar_object.instance_eval(callback, __FILE__, __LINE__)
    else
      instance_eval(callback, __FILE__, __LINE__)
    end
    Rails.logger.info("\033[0;33m后台任务执行完成!\033[0m")
  end
end
