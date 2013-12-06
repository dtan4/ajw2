require "ajw2/version"
require "ajw2/ajml"
require "ajw2/cli"
require "ajw2/generator"
require "ajw2/model/application"
require "ajw2/model/interfaces"
require "ajw2/model/databases"
require "ajw2/model/events"

module Ajw2
  def indent(text, depth)
    text.each_line.map do |line|
      line = (line.strip == "") ? "" : "  " * depth + line
    end.join("").chomp
  end
end
