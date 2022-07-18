# frozen_string_literal: true

module CarrierWave
  module Cloudflare
    module ActionView
      module ResponsiveImagesHelper
        CDN_TRANSFORM_KEYS = CarrierWave::Cloudflare::URL::ALLOWED_OPTIONS.map(&:to_sym)

        # Returns an image URL with CDN transformations applied.
        # Can process already transformed URLs, in that case the
        # options will be merged together.
        #
        # ==== Examples
        #
        #   cdn_transformed('/img.jpg', width: 400)
        #   # => '/cdn-cgi/image/width=400/img.jpg'
        #
        #   cdn_transformed('/cdn-cgi/image/width=100,fit=pad/img.jpg', width: 333)
        #   # => '/cdn-cgi/image/width=333,fit=pad/img.jpg'
        #
        def cdn_transformed(url, **options)
          base_options = BaseUploader.default_cdn_options

          CarrierWave::Cloudflare::URL.transform(
            url,
            **base_options,
            **options
          )
        end

        # Returns an image tag with with scaled variations (via `srcset`)
        # attribute for devices with different DPR values.
        #
        # The transformation of the original image should be specified via
        # options.
        #
        # ==== Examples
        #
        #   hidpi_image_tag('/bird.jpg', width: 400, height: 100, alt: 'A bird')
        #
        #   hidpi_image_tag('/bird.jpg', width: 400, drps: [1, 2])
        #
        def hidpi_image_tag(url, dprs: nil, **options)
          url = url.url if url.is_a?(CarrierWave::Uploader)
          transform, rest = split_cdn_transform_options(options)

          image_tag(
            cdn_transformed(url, **transform),
            srcset: hidpi_image_srcset(url, dprs: dprs, **transform),
            width: transform[:width],
            height: transform[:height],
            **rest
          )
        end

        # Like #hidpi_image_tag, but returns an scrset attribute value.
        def hidpi_image_srcset(url, dprs: nil, **options)
          return nil unless url.present?

          url = url.url if url.is_a?(CarrierWave::Uploader)

          (dprs || [1, 2]).map do |dpr|
            [cdn_transformed(url, dpr: dpr, **options), "#{dpr}x"].join(" ")
          end.join(", ")
        end

        # Returns a reponsive image tag with variations.
        #
        # ==== Examples
        #
        #   responsive_image_tag('/bird.jpg', width: 1200, sizes:
        #                        { phone: 600, tablet: 800 })
        #
        def responsive_image_tag(url, width:, sizes: nil, dprs: [1, 2], **options)
          url = url.url if url.is_a?(CarrierWave::Uploader)

          if sizes.nil?
            return hidpi_image_tag(url, width: width, **options)
          end

          sizes[:default] = width

          breakpoints = {
            phone: "(max-width: 767px)",
            mobile: "(max-width: 767px)", # an alias for :phone
            tablet: "(max-width: 1023px)",
            laptop: "(max-width: 1279px)",
            desktop: "(min-width: 1280px)",
            default: nil
          }

          sizes_attr = breakpoints.map do |device, media|
            next nil unless sizes[device]

            [media, "#{sizes[device]}px"].compact.join(" ")
          end.compact.join(", ")

          transform, rest = split_cdn_transform_options(options)
          base_version = cdn_transformed(url, width: width, **transform)

          # construct the array of available variation sizes in `srcset`
          variations = scrset_variations_from_breakpoints(sizes, dprs: dprs)

          srcset = variations.map do |size|
            scale = (size.to_f / width).round(2)
            [cdn_transformed(url, width: width, **transform, dpr: scale), "#{size}w"]
          end

          image_tag(
            base_version,
            srcset: srcset,
            sizes: sizes_attr,
            width: width,
            height: transform[:height],
            **rest
          )
        end

        def scrset_variations_from_breakpoints(breakpoints, dprs:, granularity: 180)
          # [300, 900] => [300, 600, 900, 1800]
          doubled = breakpoints.values.product(dprs).map { |s, d| (s * d).round }

          # [100, 101, 150, 250, 320] => [100, 250, 320]
          doubled.uniq { |s| s / granularity }
        end

        # returns a pair of transformation options and other options
        def split_cdn_transform_options(options)
          [
            options.slice(*CDN_TRANSFORM_KEYS),
            options.except(*CDN_TRANSFORM_KEYS)
          ]
        end
      end
    end
  end
end
