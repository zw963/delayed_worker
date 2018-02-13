require 'bundler'
require 'active_record'
require 'delayed_worker'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
