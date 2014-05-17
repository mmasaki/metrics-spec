require_relative "spec_helper"

include MetricsSpec

describe MetricsSpec do
  describe Helpers do
    describe "metrics" do
      before { include Helpers }
      subject { metrics("foo") }
      it { should be_a Metrics }
    end
  end

  describe Metrics do
    let(:query_string) { "@tag:foo.bar" }
    subject  { Metrics.new(query_string) }
    it { expect(subject.query_string).to eq query_string }

    describe "count" do
      let(:count) { 1 }

      before do 
        client = double("client")
        expect(client).to receive(:count) do
          { "count" => count }
        end
        expect(MetricsSpec).to receive(:client) { client }
      end

      it { expect(subject.count).to eq count }
    end

    describe "empty?" do
      before do
        client = double("client")
        expect(client).to receive(:count) do
          { "count" => 0 }
        end
        expect(MetricsSpec).to receive(:client) { client }
      end

      subject { metrics("foo") }

      it { should be_empty }
    end

    describe "last" do
      let(:item1) { { "foo" => "bar" } }
      let(:item2) { { "hoge" => "fuga" } }
      before do 
        client = double("client")
        expect(client).to receive(:search) do
          { 
            "hits" => {
              "hits" => [
                item1,
                item2
              ]
            }
          }
        end
        expect(MetricsSpec).to receive(:client) { client }
      end

      context "without arguments" do
        it { expect(subject.last).to eq item1 }
      end

      context "n = 2" do
        it { expect(subject.last(2)).to eq [item1, item2] }
      end
    end

    describe "min" do
      let(:field) { "foo" }
      let(:min) { 42 }

      before do 
        client = double("client")
        expect(client).to receive(:search) do
          { 
            "aggregations" => { 
              field => {
                "value" => min
              }
            }
          }
        end
        expect(MetricsSpec).to receive(:client) { client }
      end

      it { expect(subject.min(field)).to eq min }
    end

    describe "range" do
      let(:range_metrics) { metrics("foo").range("field", gt: "now-2m") }
      let(:expected_filter) do
        {
          range: {
            "field" => {
              gt: "now-2m"
            }
          }
        }
      end

      subject { range_metrics.filters }
      it { expect(subject).to include expected_filter }

      context "chain" do
        let(:range_metrics) { metrics("foo").range("field1", gt: "now-2m").range("field2", gt: "now-2m") }
        let(:filter1) do
          {
            range: {
              "field1" => {
                gt: "now-2m"
              }
            }
          }
        end
        let(:filter2) do
          {
            range: {
              "field2" => {
                gt: "now-2m"
              }
            }
          }
        end

        subject { range_metrics.filters }
        it { expect(subject).to include filter1 }
        it { expect(subject).to include filter2 }
      end
    end
  end
end
