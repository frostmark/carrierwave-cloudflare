# frozen_string_literal: true

require 'carrierwave/cloudflare/url/query_string'

module CarrierWave::Cloudflare
  module URL
    ALLOWED_OPTIONS = %w[width height dpr fit gravity quality format onerror metadata].freeze

    module_function

    def should_modify_path?
      ::CarrierWave::Cloudflare.cloudflare_transform
    end

    def extract(url)
      uri = URI.parse(url)
      options = {}

      if should_modify_path?
        if %r{/cdn-cgi/image/([^/]+)(/.*)} =~ uri.path
          formatted = $LAST_MATCH_INFO[1]
          original_path = $LAST_MATCH_INFO[2]

          options = parse_options(formatted)
          uri.path = original_path
        end
      else
        query = QueryString.new(uri.query)

        if query.key?('cdn-cgi')
          options = parse_options(query['cdn-cgi'], separator: '.', assigner: '-')
        end
      end

      [uri, options]
    end

    def transform(url, **options)
      uri, existing_opts = extract(url)
      options = existing_opts.merge(options.transform_keys(&:to_s))

      pairs = sanitized_options(options)

      if pairs.empty?
        url
      else
        append_options!(uri, pairs)
        uri.to_s
      end
    end

    def append_options!(uri, options)
      if should_modify_path?
        segment = '/cdn-cgi/image/' + options.map { |k, v| "#{k}=#{v}" }.join(',')
        uri.path = segment + uri.path
      else
        uri.query = QueryString.new(uri.query).tap do |params|
          # the format is "width-500.height.200", only safe symbols are used
          param_with_options = options.map { |k, v| "#{k}-#{v}" }.join('.')

          params['cdn-cgi'] = param_with_options
        end.to_query
      end
    end

    def sanitized_options(options)
      ordered = options.map do |k, v|
        idx = ALLOWED_OPTIONS.index(k)
        [idx, [k, v]]
      end

      filtered = ordered.select { |i,| i }.sort

      filtered.map do |_, (k, v)|
        v = v.join('x') if v.is_a?(Array)
        [k, v]
      end
    end

    # converts strings "w=foo,h=bar" into hashes
    def parse_options(str, separator: ',', assigner: '=')
      kv = str.split(separator).map { |s| s.strip.split(assigner) }
      Hash[kv]
    end
  end
end
