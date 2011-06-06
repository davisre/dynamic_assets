
module DynamicAssets
  require 'dynamic_assets/engine' if defined? Rails
end

require 'dynamic_assets/cssmin'
require 'dynamic_assets/core_extensions'
require 'dynamic_assets/config'
require 'dynamic_assets/controller'
require 'dynamic_assets/manager'
require 'dynamic_assets/reference'
require 'dynamic_assets/reference/javascript_reference'
require 'dynamic_assets/reference/stylesheet_reference'
require 'dynamic_assets/view_context'
