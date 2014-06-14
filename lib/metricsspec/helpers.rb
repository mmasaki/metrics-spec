module MetricsSpec
  module Helpers
    def metrics(query_string, **options)
      return Metrics.new(query_string)
    end

    def search(*args)
      ::MetricsSpec.client.search(*args)
    end

    def localhost
      RSpec.configuration.host
    end

    def failed(exception_class=RSpec::Expectations::ExpectationNotMetError)
      after do |example|
        yield(example) if example.exception.is_a?(exception_class)
      end
    end
  end
end
