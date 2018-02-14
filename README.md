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

### run worker in Rails model.

```
# == Schema Information

# Table name: test_delayed_workers

#  text :string(255)

class TestDelayedWorker < ActiveRecord::Base
  def update_column!
    add_delayed_worker job_name: 'change text value' do
      # ... do heavy task here in worker asynchronous.
      # e.g. invoke exteral API or do heavy SQL query
      
      # when done, we update text column.
      update(text: 'new_value')
    end
  end
end


class TestDelayedWorkerController < ActionController::Base
  def update_column
    record = TestDelayedWorker.find(params[:id])
    # invoke delayed worker
    record.update_column!
  end
end
```

### run worker in controller action
 ```
class TestDelayedWorkerController < ActionController::Base
  def update_text_column
    id = params[:id]
    new_params = {
      'text' => params[:text]
    }
    # we must use `params: new_params` to pass current context variable into block.
    add_delayed_worker job_name: 'change text value use params in controller', subject_id: id, params: new_params do
      record = TestDelayedWorker.find(subject_id)
      record.update(text: params['text'])
    end
  end
end
```

### Run in a simple class

```
class SimpleDelayedWorker
  include DelayedWorker::Concern
  
  def some_method
    add_delayed_worker job_name: 'simple delayed worker', time: 10 do
      print 'run asynchronous after 10 seconds'
    end
  end
end
 ```
 
 __IMPORTANT__ some trap you must to know:
 
 1. Only support `do ...end` block, and `do` must not same line as `end`!
 2. if need use variables defined in add_delayed_worker invoked, only support use `params` named parameter pass in.
 
  ## Support

  * MRI 1.9.3+
  * Rubinius 2.2+

## Limitations

No known limit.

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
