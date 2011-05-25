require 'jsmin'

module DynamicAssets

  class JavascriptReference < Reference

    def formats
      %w(js)
    end

    def type
      :javascripts
    end

    def minify(content_string)
      JSMin.minify content_string
    end

  end

end
