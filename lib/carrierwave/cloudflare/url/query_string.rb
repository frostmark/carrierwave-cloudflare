require 'rack/utils'

module CarrierWave::Cloudflare::URL
  class QueryString < Hash

    Parser = Object.new.tap do |obj|
      obj.extend(Rack::Utils)

      # these methods are private in Rack::Utils
      obj.singleton_class.instance_eval { public :build_query, :parse_query }
    end

    def initialize(query = '')
      super()
      self.merge!(Parser.parse_query(query))
    end

    def to_query
      result = Parser.build_query(self)
      result unless result.empty?
    end

    alias_method :to_s, :to_query
  end
end
