# MetricSspec

MetricSpec is a tool for testing your server's metrics in elasticsearch.

## Usage

```ruby:spec_helper.rb
require "metricsspec"

RSpec.configure do |c|
  c.elasticsearch = {
    host: "localhost"
  }
end

```

```ruby:cpu_spec.rb
describe metrics("@tag:dstat.cpu-usr").avg("value") do
  it { should be < 90 }
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/metricsspec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
