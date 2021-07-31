require "rails/railtie"

module CarrierWave
  module Cloudflare
    class Railtie < ::Rails::Railtie
      initializer "carrierwave-cloudflare.action_view" do |_app|
        ActiveSupport.on_load :action_view do
          require "carrierwave/cloudflare/action_view/responsive_images_helper"

          include CarrierWave::Cloudflare::ActionView::ResponsiveImagesHelper
        end
      end
    end
  end
end
