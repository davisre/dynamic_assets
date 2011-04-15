
module DynamicAssetsHelpers

    def stylesheet_asset_tag(group_key, http_attributes = {})
      DynamicAssets::Manager.asset_references_for_group_key(:stylesheets, group_key).map do |asset_ref|
        path = stylesheet_asset_path asset_ref.name
        path << "?#{asset_ref.mtime.to_i.to_s}" if asset_ref.mtime.present?

        tag :link, {
          :type   => "text/css",
          :rel    => "stylesheet",
          :media  => "screen",
          :href   => asset_url_for_path(path)
        }.merge!(http_attributes)

      end.join.html_safe
    end

    def javascript_asset_tag(group_key, http_attributes = {})
      DynamicAssets::Manager.asset_references_for_group_key(:javascripts, group_key).map do |asset_ref|
        path = javascript_asset_path asset_ref.name
        path << "?#{asset_ref.mtime.to_i.to_s}" if asset_ref.mtime.present?

        content_tag :script, "", {
          :type => "text/javascript",
          :src  => asset_url_for_path(path)
        }.merge!(http_attributes)

      end.join.html_safe
    end


  protected

    def asset_url_for_path(path)
      raise "expected a path, not a full URL: #{path}" unless path.relative_url?
      path = "/" + path unless path[0,1] == "/"
      host = compute_asset_host path

      if host
        "#{host}#{path}"
      else
        path
      end
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
