
module DynamicAssets
  class Engine < Rails::Engine

      initializer 'dynamic_assets.config' do |app|
        Manager.init "#{app.root}/config/assets.yml"
        ActionView::Base.send :include, DynamicAssetsHelpers
      end

  end
end
