
module DynamicAssetsHelpers

  def stylesheet_asset_tag(group_key, http_attributes = {})
    DynamicAssets::Manager.asset_references_for_group_key(:stylesheets, group_key).map do |asset_ref|

      tag :link, {
        :type   => "text/css",
        :rel    => "stylesheet",
        :media  => "screen",
        :href   => asset_url(asset_ref)
      }.merge!(http_attributes)

    end.join.html_safe
  end

  def javascript_asset_tag(group_key, http_attributes = {})
    DynamicAssets::Manager.asset_references_for_group_key(:javascripts, group_key).map do |asset_ref|

      content_tag :script, "", {
        :type => "text/javascript",
        :src  => asset_url(asset_ref)
      }.merge!(http_attributes)

    end.join.html_safe
  end


protected

  def asset_path(asset_ref)
    path_args = []
    path_args << asset_ref.name
    path_args << { :signature => asset_ref.signature } if asset_ref.signature.present?

    case asset_ref
    when DynamicAssets::StylesheetReference then stylesheet_asset_path *path_args
    when DynamicAssets::JavascriptReference then javascript_asset_path *path_args
    else raise "Unknown asset type: #{asset_ref}"
    end
  end

  def asset_url(asset_ref)
    path = asset_path asset_ref
    path = "/" + path unless path[0,1] == "/"

    host = compute_asset_host path
    host ? "#{host}#{path}" : path
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
        (host =~ /%d/) ? host % (source.hash % 4) : host
      end
    end
  end
end
