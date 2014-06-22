module Ajw2::Util
  # Insert indentation
  # @param [String] text multi-line text to be inserted
  # @param [Integer] depth depth of indentation
  # @return [String] text which indentation is inserted
  def indent(text, depth)
    fail ArgumentError, "Negative number is given" if depth < 0

    text.each_line.map do |line|
      (line.strip == "") ? "" : "  " * depth + line
    end.join("").chomp
  end

  # Convert Hash key from String to Symbol
  # @param [Hash] argument Hash to be converted
  # @return [Hash] converted Hash
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
end
