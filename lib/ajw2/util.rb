module Ajw2::Util
  def indent(text, depth)
    raise ArgumentError, "Negative number is given" if depth < 0

    text.each_line.map do |line|
      line = (line.strip == "") ? "" : "  " * depth + line
    end.join("").chomp
  end
end
