require 'test_helper'

class TestDelayedWorker < ActiveRecord::Base
  def update_column!
    add_delayed_worker job_name: 'change text value' do
      update(text: 'text_after_change')
    end
  end

  def update_column_use_params!
    add_delayed_worker job_name: 'change text value use params', params: {text: 'params text'} do
      update(text: params['text'])
    end
  end
end

class DelayedWorkerTest < Minitest::Test
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
end
