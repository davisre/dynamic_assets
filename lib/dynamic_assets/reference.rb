require 'digest/sha1'

module DynamicAssets
  class Reference

    attr_accessor :name

    #
    #  Class Methods
    #

    def self.new_for_type(type, attrs = {})
      case type
      when :stylesheets then StylesheetReference
      when :javascripts then JavascriptReference
      else raise "unknown type: #{type}"
      end.new attrs
    end

    def initialize(attrs = {})
      @name = attrs[:name]
      @member_names = attrs[:member_names]
    end


    #
    #  Instance Methods
    #

    def formats
      raise "subclasses of #{self.class} should implement this method to return an array of formats"
    end

    def member_names=(some_names)
      @member_names = some_names
    end

    def member_names
      @member_names ||= [name]
    end

    def paths
      member_names.map { |member_name| path_for_member_name member_name }
    end

    def member_root
      return @member_root if @member_root

      possible_roots = ["#{Rails.root}/app/assets/#{type.to_s}", "#{Rails.root}/app/views/#{type.to_s}"]
      @member_root = File.find_existing(possible_roots) || possible_roots.first
    end

    def content(context, for_signature = false)
      @context = context
      s = combine_content for_signature
      s = minify s if DynamicAssets::Manager.minify? && !for_signature
      s
    end

    def signature(context)
      # Note that the signature is based on the context at the time the
      # asset helper is called, which is different from the context at
      # the time of asset rendering.
      #
      # To force a change in signature, set or update the ASSET_VERSION
      # config variable.

      (ENV['ASSET_VERSION'] || "") + Digest::SHA1.hexdigest(content(context, true))
    end

    def minify(content_string)
      raise "subclasses of #{self.class} should implement this method"
    end


  protected

    def path_for_member_name(member_name)
      formats.each do |format|
        path = "#{member_root}/#{member_name}.#{format}"
        return path if raw_content_exists? path

        path = "#{member_root}/#{member_name}.#{format}.erb"
        return path if raw_content_exists? path
      end

      raise "Couldn't find #{type} asset named #{member_name} in #{member_root} with " +
        "one of these formats: #{formats.join ','}"
    end

    def format_for_member_name(name)
      format_for_path path_for_member_name(name)
    end

    def format_for_path(path)
      ext = File.extname path
      ext = File.extname(File.basename path, ext) if ext == ".erb"

      ext[1..-1].to_sym   # Remove the dot, symbolize
    end

    def path_is_erb?(path)
      File.extname(path) == ".erb"
    end

    def combine_content(for_signature)
      member_names.map do |member_name|
        read_member member_name, for_signature
      end.join "\n"
    end

    def read_member(member_name, for_signature)
      path = path_for_member_name member_name
      content_string = get_raw_content path

      if path_is_erb?(path)
        raise "ERB requires a context" unless @context
        begin
          content_string = ERB.new(content_string).result @context
        rescue StandardError => e
          raise e.exception(parse_erb_error(e, path, content_string) ||
            "Error in ERB #{path}, unknown line number: #{e}")
        end
      end

      content_string
    end

    def raw_content_exists?(path)
      File.exists? path
    end

    def get_raw_content(path)
      File.open(path, "r") { |f| f.read }
    end

    def parse_erb_error(error, path, content_string)
      # Exception parsing inspired by HelpfulERB

      return nil unless error.backtrace.first =~ /^[^:]+:(\d+):in /

      line_number = $1.to_i
      lines = content_string.split /\n/

      min = [line_number - 5, 0].max
      max = [line_number + 1, lines.length].min

      width = max.to_s.size

      message = "Error in ERB '#{path}' at line #{line_number}:\n\n" +
        (min..max).map do |i|
          n = i + 1
          marker = n == line_number ? "*" : ""
          "%2s %#{width}i %s" % [marker, n, lines[i]]
        end.join("\n") +
        "\n\n#{error.class}: #{error.message}"
    end
  end
end
