
Rails.application.routes.draw do

  match '/assets/javascripts/:name.js' => 'assets#show_javascript', :as => :javascript_asset,
    :format => "js",                        # Important for action-caching non-HTML resources
    :constraints => { :name => /[^ ]+/ }    # By default, segments can't have dots. We allow all but space.

  match '/assets/stylesheets/:name.css' => 'assets#show_stylesheet', :as => :stylesheet_asset,
    :format => "css",                       # Important for action-caching non-HTML resources
    :constraints => { :name => /[^ ]+/ }    # By default, segments can't have dots. We allow all but space.

end
