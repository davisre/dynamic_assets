
module DynamicAssets
  class ViewContext

    def self.get(controller)
      controller.view_context.tap do |c|
        class << c
          def get_binding
            binding
          end
        end
      end.get_binding
    end

  end
end
