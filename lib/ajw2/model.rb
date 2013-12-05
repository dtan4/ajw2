module Ajw2::Model
  def indent(text, depth)
    text.each_line.map do |line|
      line = (line.strip == "") ? "" : "  " * depth + line
    end.join("")
  end
end
