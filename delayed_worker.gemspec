require File.expand_path('../lib/delayed_worker/version', __FILE__)

Gem::Specification.new do |s|
  s.name                        = 'delayed_worker'
  s.version                     = DelayedWorker::VERSION
  s.date                        = Time.now.strftime('%F')
  s.required_ruby_version       = '>= 2.2.2'
  s.authors                     = ['Billy.Zheng']
  s.email                       = ['vil963@gmail.com']
  s.summary                     = 'Run delayed job easy! '
  s.description                 = 'A easy-use and clean wrapper for sidekiq worker.'
  s.homepage                    = 'http://github.com/zw963/delayed_worker'
  s.license                     = 'MIT'
  s.require_paths               = ['lib']
  s.files                       = `git ls-files bin lib *.md LICENSE`.split("\n")
  s.files                      -= Dir['images/*.png']
  s.executables                 = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f) }

  s.add_runtime_dependency 'sidekiq', '~> 4.0'
  s.add_runtime_dependency 'method_source', '~> 0.8'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3', '> 1.3'
  s.add_development_dependency 'appraisal'
end
