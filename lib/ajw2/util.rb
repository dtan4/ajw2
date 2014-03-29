module Ajw2::Util
  # Insert indentation
  # @param [String] text multi-line text to be inserted
  # @param [Integer] depth depth of indentation
  # @return [String] text which indentation is inserted
  def indent(text, depth)
    raise ArgumentError, "Negative number is given" if depth < 0

    text.each_line.map do |line|
      line = (line.strip == "") ? "" : "  " * depth + line
    end.join("").chomp
  end

  # Check whether given Hash is valid
  # @param [Hash] hash Hash to be checked
  # @param [RegExp] regexp regular-expression pattern to judge validatation
  # @return [Boolean] whether given Hash is valid
  def valid_hash?(hash, regexp = /\A[^'"]+\z/)
    raise ArgumentError, "Non-Hash argument is given" unless hash.kind_of? Hash
    valid_value?(hash, regexp)
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

  private

  def valid_value?(value, regexp)
    case value
    when String
      return false unless value =~ regexp
    when Hash
      return false unless value.each_value.inject(true) { |res, val| res &= valid_value?(val, regexp) }
    when Array
      return false unless value.inject(true) { |res, val| res &= valid_value?(val, regexp) }
    else

    end

    true
  end
end
