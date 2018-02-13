require 'test_helper'

class TestDelayedWorker < ActiveRecord::Base
  def change_text_in_delayed_worker!
    add_delayed_worker job_name: 'change text value' do
      update(text: 'text_after_change')
    end
  end
end

class DelayedWorkerTest < Minitest::Test
  def test_update_active_record_asynchronous
    test1 = TestDelayedWorker.create(text: 'text_before_change')
    assert test1.persisted?
    assert_equal 'text_before_change', test1.text
    assert_equal 0, DelayedWorker.jobs.size
    test1.change_text_in_delayed_worker!
    assert_equal 1, DelayedWorker.jobs.size
    assert_equal 'text_before_change', test1.reload.text
    DelayedWorker.drain
    assert_equal 'text_after_change', test1.reload.text
  end
end
