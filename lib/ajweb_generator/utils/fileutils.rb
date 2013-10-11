module AjwebGenerator
  class FileUtils
    def self.write_file(filename, text, overwrite)
      return false if File.exists?(filename) && !overwrite
      return true
    end
  end
end
