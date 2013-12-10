module Ajw2::Util
  def indent(text, depth)
    raise ArgumentError, "Negative number is given" if depth < 0

    text.each_line.map do |line|
      line = (line.strip == "") ? "" : "  " * depth + line
    end.join("").chomp
  end

  def valid_hash?(hash, regexp = /\A[^'"]+\z/)
    raise ArgumentError, "Non-Hash argument is given" unless hash.kind_of? Hash
    valid_value?(hash, regexp)
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

    return true
  end
end
