require "simplecov"
require "simplecov-rcov"
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ajw2'

def fixture_path(file)
  File.expand_path("../fixtures/#{file}", __FILE__)
end
