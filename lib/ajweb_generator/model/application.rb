module AjwebGenerator
  class Application
    DEFAULT_HTML_NAME = "/index.html"
    DEFAULT_CSS_NAME = "/index.css"
    DEFAULT_JS_NAME = "/index.js"

    def generate(dirname)
      html_generate(dirname)
      css_generate(dirname)
      js_generate(dirname)
      db_generate(dirname)
    end

    def html_generate(dirname)
      htmlname = dirname << DEFAULT_HTML_NAME
      html = ""
      AjwebGenerator::FileUtils.write_file(htmlname, )
    end

    def css_generate(dirname)
      cssname = dirname << DEFAULT_CSS_NAME
    end

    def js_generate(dirname)
      jsname = dirname << DEFAULT_JS_NAME
    end

    def db_generate(dirname)
      # TODO
    end
  end
end
