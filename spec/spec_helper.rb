$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ajw2'

def fixture_path(file)
  File.expand_path("../fixtures/#{file}", __FILE__)
end

def symbolize_keys(argument)
  if argument.class == Hash
    argument.inject({}) do |result, (key, value)|
      result[key.to_sym] = symbolize_keys(value)
      result
    end
  elsif argument.class == Array
    argument.map { |arg| symbolize_keys(arg) }
  else
    argument
  end
end
