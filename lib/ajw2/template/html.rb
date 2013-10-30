require "erb"

module Ajw2::Template
  class HTML
    def make_header(options)
      raise Exception unless options[:title]

      headers = ['<head>']
      headers << '<meta charset="utf-8">'
      headers << '<title><%= options[:title] %></title>'
      headers << '</head>'

      ERB.new(headers.join("\n") + "\n").result(binding)
    end
  end
end
