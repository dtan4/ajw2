module AjwebGenerator
  class FileUtils
    def self.write_file(filename, text, overwrite)
      return false if File.exists?(filename) && !overwrite
      open(filename, "w+") { |f| f.puts text }
      true
    end
  end
end
