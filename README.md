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
describe "cpu usage" do
  let(:cpu_usr) { metrics("@tag:dstat.cpu.usr").within(1.hour)["value"] }
  let(:cpu_sys) { metrics("@tag:dstat.cpu.sys").within(1.hour)["value"] }

  it "%usr + %sys shoud be less than 90" do
    expect(cpu_usr.avg + cpu_sys.avg).to be < 90
  end
end

describe "network" do
  describe "receive" do
    let(:net_receive) { metrics("@tag:dstat.net.recv").within(1.hour)["value"] }

    it "average should be less than 2 megabyte" do
      expect(net_receive.avg).to be < 1.megabyte
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/metricsspec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
