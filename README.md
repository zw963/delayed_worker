# DelayedWorker [![Build Status](https://travis-ci.org/zw963/delayed_worker.svg?branch=master)](https://travis-ci.org/zw963/delayed_worker) [![Gem Version](https://badge.fury.io/rb/delayed_worker.svg)](http://badge.fury.io/rb/delayed_worker)

This gem is intend for write delayed job with easy and clean.

## Philosophy

We hope to see delayed executed business logic clealy in where add it into, so, all we need to be done is 
just use a `do ... end block` to wrap delayed job code, it will work as expected.

## Getting Started

Install via Rubygems

    $ gem install delayed_worker

OR ...

Add to your Gemfile

    gem 'delayed_worker'

## Usage

### run worker With ActiveRecord.

```rb
# == Schema Information

# Table name: test_delayed_workers

# some_column                   :string(255)
# delayed_worker_disabled       :boolean          default(TRUE)
# delayed_worker_scheduled_at   :datetime

class TestDelayedWorkerController < ActionController::Base
  def update_column
    record = TestDelayedWorker.find(params[:id])
    
    add_delayed_worker job_name: 'update some_column value' do
    # all code in block will be run asynchronous in delayed worker.
    # do heavy task here, e.g. invoke exteral API or do heavy SQL query
    # ...
    
    update(some_column: 'new_value') # can use any activerecord object method here to update record
    # ...
    # You can outout log to `log/delayed_worker.log` with following code:
    # DelayedWorker::Logger.logger.info 'logger something'
    end
  end
end
```
If you want to disabled scheduled job before executed, you can add a `delayed_worker_disabled` boolean column to table.
if this column is `true`, scheduled job will just do noop.

If you want job is execute in some future date, you need add a `delayed_worker_scheduled_at` column into table, and pass in 
`scheduled_at` named parameter, with a integer(seconds after now) or any time like object which have a `to_time` method. 
(e.g. Date, Time, DateTime, ActiveSupport::TimeWithZone)

following is a example:

```rb
class TestDelayedWorkerController < ActionController::Base
  def update_column
    record = TestDelayedWorker.find(params[:id], scheduled_at: 3600)

    add_delayed_worker job_name: 'update some_column value' do
      update(some_column: 'new_value') # can use any activerecord object method here to update record
    end
  end
end
 ```
 
 If you want to change scheduled date before job executed, just need change column `delayed_worker_scheduled_at` value, and
 run add_delayed_worker again to add a new job into queue, old job will just do noop, and new job will work.

### run worker in controller action
 ```rb
class TestDelayedWorkerController < ActionController::Base
  def update_column
    id = params[:id]
    new_params = {some_column: params[:some_column]}
    
    # we must use `params: {key1: value1, key2...}` to pass local variable into block.
    add_delayed_worker job_name: 'update some column value use params in controller', subject_id: id, params: new_params do
      record = TestDelayedWorker.find(subject_id)
      record.update(some_column: params[:some_column]) # get passed in value with: params[:some_key] or params['some_key']
    end
  end
end
```

### Run in a simple class

```rb
class SimpleDelayedWorker
  include DelayedWorker::Concern
  
  def some_method
    add_delayed_worker job_name: 'simple delayed worker', time: 10 do
      print 'run asynchronous after 10 seconds'
    end
  end
end
 ```
 
 add_delayed_worker method supported parameter is [here](https://github.com/zw963/delayed_worker/blob/master/lib/delayed_worker/concern.rb#L6-L11)
 
 __IMPORTANT__ some trap you must to know:
 
 1. Only support `do ...end` block, and `do` must not same line as `end`!
 2. if need use variables defined in add_delayed_worker invoked, only support use `params` named parameter pass in.
 
## Support

  CRuby 2.2 2.3 2.4 2.5 is support.
  
## Dependency

  [sidekiq](https://github.com/mperham/sidekiq)
  [method_source](https://github.com/banister/method_source)

## History

  See [CHANGELOG](https://github.com/zw963/delayed_worker/blob/master/CHANGELOG) for details.

## Contributing

  * [Bug reports](https://github.com/zw963/delayed_worker/issues)
  * [Source](https://github.com/zw963/delayed_worker)
  * Patches:
    * Fork on Github.
    * Run `bundle install`.
    * Create your feature branch: `git checkout -b my-new-feature`.
    * Commit your changes: `git commit -am 'Add some feature'`.
    * Push to the branch: `git push origin my-new-feature`.
    * Send a pull request :D.

## license

Released under the MIT license, See [LICENSE](https://github.com/zw963/delayed_worker/blob/master/LICENSE) for details.
