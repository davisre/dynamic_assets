
Rails.application.routes.draw do

  match '/assets/javascripts(/:timestamp)/:name.:format' => 'assets#show_javascript',
    :as => :javascript_asset,
    :format => "js",              # Important for action-caching non-HTML resources
    :constraints => {
      :name => /[^ ]+/,           # By default, route segments can't have dots. We allow all but space.
      :timestamp => /\d+/
    }

  match '/assets/stylesheets(/:timestamp)/:name.:format' => 'assets#show_stylesheet',
    :as => :stylesheet_asset,
    :format => "css",             # Important for action-caching non-HTML resources
    :constraints => {             # By default, segments can't have dots. We allow all but space.
      :name => /[^ ]+/,
      :timestamp => /\d+/
    }

end
