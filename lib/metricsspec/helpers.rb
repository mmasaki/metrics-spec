module MetricsSpec
  module Helpers
    def metrics(query_string, **options)
      return Metrics.new(query_string)
    end

    def search(*args)
      ::MetricsSpec.client.search(*args)
    end

    def hosts
      RSpec.configuration.hosts.dup
    end
  end
end
