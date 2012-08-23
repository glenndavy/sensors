# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sensors/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Glenn Davy"]
  gem.email         = ["glenn@davy.net.au"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sensors"
  gem.require_paths = ["lib"]
  gem.version       = Sensors::VERSION

  gem.add_development_dependency("guard")
  gem.add_development_dependency("guard-minitest")
  gem.add_development_dependency("ruby_gntp")
  gem.add_development_dependency("debugger")
end
