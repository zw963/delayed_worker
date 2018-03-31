require 'test_helper'
require 'delayed_worker'

class TestDelayedWorker < ActiveRecord::Base
  def update_column!
    add_job_into_delayed_worker job_name: 'change text value' do
      update(text: 'text_after_change')
    end
  end

  def update_column_use_params!
    add_job_into_delayed_worker job_name: 'change text value use params', params: {text: 'params text'} do
      update(text: params[:text])
    end
  end
end

class TestDelayedWorkerController < ActionController::Base
  def test_delayed_worker
    id = TestDelayedWorker.last.id
    add_job_into_delayed_worker job_name: 'change text value use params in controller', subject_id: id, params: {text: 'text_from_controller_params'} do
      record = TestDelayedWorker.find(subject_id)
      record.update(text: params[:text])
    end
  end
end

class SimpleDelayedWorker
  include DelayedWorker::Concern
  def test_delayed_worker
    add_job_into_delayed_worker job_name: 'simple delayed worker' do
      $stdout.print 'delayed worker is run!'
    end
  end

  def test_delayed_worker_run_after_10_seconds
    add_job_into_delayed_worker job_name: 'simple delayed worker', scheduled_at: 10 do
      $stdout.print 'delayed worker is run after 10 seconds!'
    end
  end
end

class DelayedWorkerTest < Minitest::Test
  def setup
    assert TestDelayedWorker.ancestors.include? DelayedWorker::Concern
    assert TestDelayedWorkerController.ancestors.include? DelayedWorker::Concern
  end

  def test_update_active_record_column_asynchronous
    test1 = TestDelayedWorker.create(text: 'text_before_change')
    assert test1.persisted?
    assert_equal 'text_before_change', test1.text
    assert_equal 0, DelayedWorker.jobs.size
    test1.update_column!
    assert_equal 1, DelayedWorker.jobs.size
    assert_equal 'text_before_change', test1.reload.text
    DelayedWorker.drain
    assert_equal 'text_after_change', test1.reload.text
  end

  def test_update_active_record_column_use_params_asynchronous
    test1 = TestDelayedWorker.create(text: 'text_before_change')
    assert test1.persisted?
    assert_equal 'text_before_change', test1.text
    assert_equal 0, DelayedWorker.jobs.size
    test1.update_column_use_params!
    assert_equal 1, DelayedWorker.jobs.size
    assert_equal 'text_before_change', test1.reload.text
    DelayedWorker.drain
    assert_equal 'params text', test1.reload.text
  end

  def test_delayed_worker_in_controller_asynchronous
    test1 = TestDelayedWorker.create(text: 'text_before_change')
    subject = TestDelayedWorkerController.new
    assert test1.persisted?
    assert_equal 'text_before_change', test1.text
    assert_equal 0, DelayedWorker.jobs.size
    subject.test_delayed_worker
    assert_equal 1, DelayedWorker.jobs.size
    assert_equal 'text_before_change', test1.reload.text
    DelayedWorker.drain
    assert_equal 'text_from_controller_params', test1.reload.text
  end

  def test_simple_delayed_worker_asynchronous
    subject = SimpleDelayedWorker.new
    assert_output('delayed worker is run!') do
      subject.test_delayed_worker
      DelayedWorker.drain
    end
  end

  def test_simple_delayed_worker_run_after_10_seconds_asynchronous
    subject = SimpleDelayedWorker.new
    assert_output('delayed worker is run after 10 seconds!') do
      subject.test_delayed_worker_run_after_10_seconds
      DelayedWorker.drain
    end
  end
end
