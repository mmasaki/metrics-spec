require "socket"
require "rspec"
require "elasticsearch"
require "jbuilder"

module MetricsSpec
  module_function

  def client
    @@client ||= ::Elasticsearch::Client.new(RSpec.configuration.elasticsearch)
  end
end

require "metricsspec/version"
require "metricsspec/metrics"
require "metricsspec/helpers"

RSpec.configure do |c|
  c.add_setting :host, default: Socket.gethostname
  c.add_setting :host_field, default: "@host"
  c.add_setting :elasticsearch
end

include MetricsSpec::Helpers
