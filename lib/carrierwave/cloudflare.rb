# frozen_string_literal: true

require 'active_support'

require 'carrierwave/cloudflare/version'

module CarrierWave
  module Cloudflare
    extend ActiveSupport::Concern

    included do
      class_attribute :_default_cdn_options, instance_reader: false, instance_writer: false

      self._default_cdn_options = {}
    end

    module ClassMethods
      def cdn_transform(**options)
        opts = default_cdn_options.merge(options)
        self.version_options = version_options.merge(cdn_transform: opts)
      end

      def default_cdn_options(**defaults)
        return _default_cdn_options if defaults.empty?

        self._default_cdn_options = defaults
      end
    end

    def self.configure
      yield self
    end

    def self.cloudflare_transform(value = nil)
      return @cloudflare_transform if value.nil?

      @cloudflare_transform = value
    end

    def store!(*args)
      return if virtual_version?

      super(*args)
    end

    def cache!(*args)
      return if virtual_version?

      super(*args)
    end

    def retrieve_from_cache!(*args)
      return if virtual_version?

      super(*args)
    end

    def retrieve_from_store!(*args)
      return if virtual_version?

      super(*args)
    end

    def url(*args)
      if virtual_version?
        cdn_url
      else
        super(*args)
      end
    end

    def resize(**options)
      # build temporary uploader
      uploader = self.class.dup
      self.class.const_set("Uploader#{uploader.object_id}".tr('-', '_'), uploader)
      uploader.version_options = { cdn_transform: options }

      # init the instance uploader and set parent_version
      obj = uploader.new(self)
      obj.parent_version = self
      obj
    end

    private

    def virtual_version?
      self.class.version_options && self.class.version_options[:cdn_transform].present? && parent_version
    end

    def cdn_url
      if base_image_url
        CarrierWave::Cloudflare::URL.transform(
          base_image_url,
          **self.class.version_options[:cdn_transform]
        )
      end
    end

    def base_image_url
      parent_version.url
    end
  end
end

require 'carrierwave/cloudflare/url'
