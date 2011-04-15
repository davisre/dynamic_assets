
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
      "#{Rails.root}/app/assets/#{type.to_s}"
    end

    # Optionally pass context from which ERB can pull instance variables.
    def content(context = nil)
      @context = context
      s = combine_content
      s = minify s if DynamicAssets::Manager.minify?
      s
    end

    def mtime
      paths.map { |p| File.mtime p }.max
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

    def combine_content
      member_names.map do |member_name|
        read_member member_name
      end.join "\n"
    end

    def read_member(member_name)
      path = path_for_member_name member_name
      content_string = get_raw_content path
      content_string = ERB.new(content_string).result(@context) if path_is_erb?(path)
      content_string
    end

    def raw_content_exists?(path)
      File.exists? path
    end

    def get_raw_content(path)
      File.open(path, "r") { |f| f.read }
    end

  end
end
