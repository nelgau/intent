# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require 'intent/version'

Gem::Specification.new do |s|
  s.name         = "intent"
  s.version      = Intent::VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Nelson Gauthier"]
  s.email        = ["nelson@airbnb.com"]
  s.homepage     = "http://www.github.com/nelgau/intent"
  s.summary      = "Do what you intend."
  s.description  = "A gem for tracing execution and side effects."

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'

  s.add_runtime_dependency 'parser', '2.0.0.pre2'
  s.add_runtime_dependency 'segment_tree', '~> 0.1.0'
  s.add_runtime_dependency 'colored', '~> 1.2.0'
end
