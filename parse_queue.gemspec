# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "parse_queue/version"

Gem::Specification.new do |spec|
  spec.name          = "parse_queue"
  spec.version       = ParseQueue::VERSION
  spec.authors       = ["PeterCamilleri"]
  spec.email         = ["peter.c.camilleri@gmail.com"]

  spec.summary       = "The RCTP object queue for connecting parser steps."
  spec.description   = "The RCTP object queue for moving compiler tokens with nestable backtrack capability."
  spec.homepage      = "https://github.com/PeterCamilleri/parse_queue"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>=2.3.0'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'reek', "~> 5.0.2"
end
