require 'bundler'
require 'active_record'
require 'action_controller'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :test_delayed_workers, :force => true do |t|
    t.string :text
  end
end
