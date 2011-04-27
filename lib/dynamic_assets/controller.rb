
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


  protected

    def render_asset(type, name, mime_type)
      asset = Manager.asset_reference_for_name type, name
      raise ActionController::RoutingError.new "No route matches \"#{request.path}\"" unless asset

      if Manager.cache?
        response.cache_control[:public] = true
        response.cache_control[:max_age] = 365.days
        headers["Expires"] = (Time.now + 365.days).utc.httpdate
      end

      render :layout => false, :text => asset.content(binding), :content_type => mime_type
    end
  end

end
