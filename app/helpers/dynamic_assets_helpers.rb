
module DynamicAssetsHelpers

  def stylesheet_asset_tag(group_key, options = {})
    html_options, path_options = separate_options(options)
    DynamicAssets::Manager.asset_references_for_group_key(:stylesheets, group_key).map do |asset_ref|

      tag :link, {
        :type   => "text/css",
        :rel    => "stylesheet",
        :media  => "screen",
        :href   => asset_url(asset_ref, path_options)
      }.merge!(html_options)

    end.join.html_safe
  end

  def javascript_asset_tag(group_key, options = {})
    html_options, path_options = separate_options(options)
    DynamicAssets::Manager.asset_references_for_group_key(:javascripts, group_key).map do |asset_ref|

      content_tag :script, "", {
        :type => "text/javascript",
        :src  => asset_url(asset_ref, path_options)
      }.merge!(html_options)

    end.join.html_safe
  end


protected

  def asset_path(asset_ref, options = {})
    # Omit signature if we see an explicit :signature => false option.
    signature = (options[:signature] == false) ? nil :
      asset_ref.signature(DynamicAssets::ViewContext.get(controller))
    options = options.reverse_merge :name => asset_ref.name, :signature => signature

    case asset_ref
    when DynamicAssets::StylesheetReference then stylesheet_asset_path options
    when DynamicAssets::JavascriptReference then javascript_asset_path options
    else raise "Unknown asset type: #{asset_ref}"
    end
  end

  def asset_url(asset_ref, options = {})
    path = asset_path asset_ref, options
    path = "/" + path unless path[0,1] == "/"

    host = options[:host].presence || compute_asset_host(path)

    # Like Rails, add the protocol if the host lacks it.
    if controller.respond_to?(:request) && host.present? && !is_uri?(host)
      host = "#{controller.request.protocol}#{host}"
    end

    host.present? ? "#{host}#{path}" : path
  end

  # Extracted from Rails' AssetTagHelper, where it's private
  def compute_asset_host(source)
    if host = config.asset_host
      if host.is_a?(Proc) || host.respond_to?(:call)
        case host.is_a?(Proc) ? host.arity : host.method(:call).arity
        when 2
          request = controller.respond_to?(:request) && controller.request
          host.call(source, request)
        else
          host.call(source)
        end
      else
        (host =~ /%d/) ? host % hash_url(source) : host
      end
    end
  end

  def is_uri?(path)
    path =~ %r{^[-a-z]+://|^cid:}
  end

  def separate_options(options)
    path_options = {}
    [:token, :signature, :name, :host, :protocol, :port].each do |key|
      path_options[key] = options.delete(key) if options.has_key?(key)
    end
    [options, path_options]
  end

  # Don't use String#hash because it differs across VM invocations,
  # meaning different servers will map the same URL to different asset
  # hosts.
  def hash_url(url)
    l = url.length
    i = 0
    h = l
    while i < l
      h = h ^ url[i].ord
      i = i + 1
    end
    h % 4
  end

end
