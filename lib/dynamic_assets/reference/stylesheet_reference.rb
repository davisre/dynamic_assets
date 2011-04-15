
module DynamicAssets

  class StylesheetReference < Reference

    # CSS style sheets can contain relative urls like this:
    #
    #    background: url(something.png)
    #
    # The browser will look for the resource in the same location as
    # the CSS file. However, we serve static resources like images
    # from a different location, so the StylesheetReference will prepend
    # RELATIVE_URL_ROOT to each such relative url in a stylesheet.

    RELATIVE_URL_ROOT  = "/stylesheets"

    delegate :minify, :to => CSSMin

    def formats
      %w(sass scss css)
    end

    def type
      :stylesheets
    end


  protected

    # Overridden to transform URLs embedded in the CSS
    def read_member(member_name)
      content_string = super
      format = format_for_member_name member_name

      content_string = case format
      when :css
        content_string
      when :sass,:scss
        location = File.dirname path_for_member_name(member_name)
        Sass::Engine.new(content_string, :syntax => format, :load_paths => [location],
          :cache => false).render
      else raise "unknown format #{format}"
      end

      # PENDING: we could do something similar to insert the asset host,
      # although we'd need to pass some context (namely the request) down
      # from the controller to compute the asset host in the same way Rails
      # does.
      transform_urls member_name, content_string
    end


    def transform_urls(member_name, content_string)

      # Prepend url_root to each relative url that doesn't start with a slash.
      #
      # Inside fancy.css, any of these:
      #   url(one/thing.png)
      #   url('one/thing.png')
      #   url( "one/thing.png" )
      #   url(../one/thing.png)
      # will become
      #   url(/stylesheets/fancy/one/thing.png)
      #

      content_string.gsub( /url\( *['"]?([^)]*[^'"])['"]? *\)/ ) do |s|
        url = $1
        url.gsub! /^(\.\.|\.)\//, ''
        (url !~ /^\// && url.relative_url?) ? "url(#{RELATIVE_URL_ROOT}/#{member_name}/#{url})" : s
      end
    end

  end

end
