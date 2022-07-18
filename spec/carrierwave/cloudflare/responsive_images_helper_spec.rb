# frozen_string_literal: true

require "action_view"

require "spec_helper"

require "carrierwave/cloudflare/action_view/responsive_images_helper"

RSpec.describe CarrierWave::Cloudflare::ActionView::ResponsiveImagesHelper do
  let(:view) { DummyView.new }

  before do
    class BaseUploader < CarrierWave::Uploader::Base
      include CarrierWave::Cloudflare
    end

    class DummyView
      include ActionView::Helpers::AssetTagHelper
      include CarrierWave::Cloudflare::ActionView::ResponsiveImagesHelper
    end
  end

  after do
    Object.send(:remove_const, "DummyView") if defined?(::DummyView)
  end

  describe "#cdn_transformed" do
    context "when cloudflare_transform is true" do
      before do
        allow(CarrierWave::Cloudflare).to receive(:cloudflare_transform).and_return(true)
      end

      it "transforms url" do
        url = view.cdn_transformed("/img.jpg", width: 400)

        expect(url).to eql("/cdn-cgi/image/width=400/img.jpg")
      end

      it "transforms already transformed url" do
        url = view.cdn_transformed("/cdn-cgi/image/width=100,fit=pad/img.jpg", width: 400)

        expect(url).to eql("/cdn-cgi/image/width=400,fit=pad/img.jpg")
      end
    end
  end

  describe "#hidpi_image_tag" do
    context "when cloudflare_transform is true" do
      before do
        allow(CarrierWave::Cloudflare).to receive(:cloudflare_transform).and_return(true)
      end

      it "generates image tag with srcset" do
        img_tag = view.hidpi_image_tag("/img.jpg", width: 400, dprs: [1, 2, 3])
        expected_img_tag = "<img srcset=\"/cdn-cgi/image/width=400,dpr=1/img.jpg 1x, /cdn-cgi/image/width=400,dpr=2/img.jpg 2x, /cdn-cgi/image/width=400,dpr=3/img.jpg 3x\" width=\"400\" src=\"/cdn-cgi/image/width=400/img.jpg\" />"

        expect(img_tag).to eql(expected_img_tag)
      end

      it "generates image tag with width and height" do
        img_tag = view.hidpi_image_tag("/img.jpg", width: 400, height: 300, dprs: [1, 2, 3])

        expected_img_tag = "<img srcset=\"/cdn-cgi/image/width=400,height=300,dpr=1/img.jpg 1x, /cdn-cgi/image/width=400,height=300,dpr=2/img.jpg 2x, /cdn-cgi/image/width=400,height=300,dpr=3/img.jpg 3x\" width=\"400\" height=\"300\" src=\"/cdn-cgi/image/width=400,height=300/img.jpg\" />"

        expect(img_tag).to eql(expected_img_tag)
      end
    end
  end

  describe "#hidpi_image_srcset" do
    context "when cloudflare_transform is true" do
      before do
        allow(CarrierWave::Cloudflare).to receive(:cloudflare_transform).and_return(true)
      end

      it "generates image srcset" do
        img_srcset = view.hidpi_image_srcset("/img.jpg", width: 400, dprs: [1, 2, 3])
        expected_img_srcset = "/cdn-cgi/image/width=400,dpr=1/img.jpg 1x, /cdn-cgi/image/width=400,dpr=2/img.jpg 2x, /cdn-cgi/image/width=400,dpr=3/img.jpg 3x"

        expect(img_srcset).to eql(expected_img_srcset)
      end

      it "generates image srcset (uses default drps)" do
        img_srcset = view.hidpi_image_srcset("/img.jpg", width: 400)
        expected_img_srcset = "/cdn-cgi/image/width=400,dpr=1/img.jpg 1x, /cdn-cgi/image/width=400,dpr=2/img.jpg 2x"

        expect(img_srcset).to eql(expected_img_srcset)
      end
    end
  end

  describe "#responsive_image_tag" do
    context "when cloudflare_transform is true" do
      before do
        allow(CarrierWave::Cloudflare).to receive(:cloudflare_transform).and_return(true)
      end

      it "generates image responsive image tag" do
        img_tag = view.responsive_image_tag('/bird.jpg', width: 1200, sizes: { phone: 600, tablet: 800 })

        expected_img_tag = "<img srcset=\"/cdn-cgi/image/width=1200,dpr=0.5/bird.jpg 600w, /cdn-cgi/image/width=1200,dpr=1.0/bird.jpg 1200w, /cdn-cgi/image/width=1200,dpr=0.67/bird.jpg 800w, /cdn-cgi/image/width=1200,dpr=1.33/bird.jpg 1600w, /cdn-cgi/image/width=1200,dpr=2.0/bird.jpg 2400w\" sizes=\"(max-width: 767px) 600px, (max-width: 1023px) 800px, 1200px\" width=\"1200\" src=\"/cdn-cgi/image/width=1200/bird.jpg\" />"


        expect(img_tag).to eql(expected_img_tag)
      end

      it "generates image responsive image tag with height" do
        img_tag = view.responsive_image_tag('/bird.jpg', width: 200, height: 1200, sizes: { phone: 600, tablet: 800 })

        expected_img_tag = "<img srcset=\"/cdn-cgi/image/width=200,height=1200,dpr=3.0/bird.jpg 600w, /cdn-cgi/image/width=200,height=1200,dpr=6.0/bird.jpg 1200w, /cdn-cgi/image/width=200,height=1200,dpr=4.0/bird.jpg 800w, /cdn-cgi/image/width=200,height=1200,dpr=8.0/bird.jpg 1600w, /cdn-cgi/image/width=200,height=1200,dpr=1.0/bird.jpg 200w, /cdn-cgi/image/width=200,height=1200,dpr=2.0/bird.jpg 400w\" sizes=\"(max-width: 767px) 600px, (max-width: 1023px) 800px, 200px\" width=\"200\" height=\"1200\" src=\"/cdn-cgi/image/width=200,height=1200/bird.jpg\" />"


        expect(img_tag).to eql(expected_img_tag)
      end
    end
  end
end
