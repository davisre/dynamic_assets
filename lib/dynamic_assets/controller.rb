
module DynamicAssets
  module Controller

    #
    #  Actions
    #

    def show_stylesheet
      render_asset :stylesheets, params[:name], "text/css"
    end

    def show_javascript
      render_asset :javascripts, params[:name], "text/javascript"
    end


  private

    def render_asset(type, name, mime_type)
      asset = Manager.asset_reference_for_name type, name
      raise ActionController::RoutingError.new "No route matches \"#{request.path}\"" unless asset

      cache_asset asset
      render :layout => false, :text => asset.content(ViewContext.get(self)), :content_type => mime_type
    end

    def cache_asset(asset)
      return unless Manager.cache? && params[:signature]

      response.cache_control[:public] = true
      response.cache_control[:max_age] = 365.days
      headers["Expires"] = (Time.now + 365.days).utc.httpdate
    end

  end

end
