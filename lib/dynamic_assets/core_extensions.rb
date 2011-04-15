
class String

  # Returns true iff the receiver seems to be a relative, not a full, URL.
  # By "relative url" we mean a URL with no host info, although it may
  # begin with a slash.
  def relative_url?
    regexp = /^[^:\/]*:\/\/[^\/]*/
    self[regexp].nil?
  end

end

class Object

  def if_present(*value)
    raise ArgumentError, "Specify either a value or a block but not both" if value.empty? != block_given?
    raise ArgumentError, "Too many arguments. Expected one." if value.length > 1

    if !self.present?
      self
    elsif block_given?
      yield self
    else
      value.first
    end
  end

end

class File

  def self.find_existing(paths)
    paths.each do |path|
      return path if File.exists? path
    end

    nil
  end

end
