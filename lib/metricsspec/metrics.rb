module MetricsSpec
  class Metrics
    HostField = "@host"

    def initialize(query_string, host_field: nil)
      @query_string = query_string
      host = RSpec.configuration.host
      host_field = host_field || RSpec.configuration.host_field
      host_filter = {
        term: {
          host_field => host
        }
      }
      @filters = [host_filter]
    end

    attr_reader :query_string, :aggs, :filters

    def initialize_copy(orig)
      @filters = orig.filters.dup
    end

    def count
      body = Jbuilder.encode do |json|
        json.query do
          json.query_string do
            json.query @query_string
          end
        end
        json.filter build_filters() unless @filters.empty?
      end
      return MetricsSpec.client.count(body: body)["count"]
    end

    TimestampDescSorter = [{ "@timestamp" => { order: "desc" } }]

    def last(n=1)
      body = Jbuilder.encode do |json|
        json.size n
        json.sort do
          json.array! TimestampDescSorter
        end
      end
      hits = search(body)["hits"]["hits"]
      hits.map {|hit| hit["_source"] }
      return hits.first if n == 1
      return hits
    end

    def empty?
      count.zero?
    end

    SingleValueAggs = [:min, :max, :sum, :avg, :value_count, :cardinality].freeze
    SingleValueAggs.each do |aggregation_type|
      define_method(aggregation_type) do |field|
        return aggregation(aggregation_type, field)["value"]
      end
    end

    MultiValueAggs = [:stats, :extended_stats, :percentiles].freeze
    MultiValueAggs.each do |aggregation_type|
      define_method(aggregation_type) do |field|
        return aggregation(aggregation_type, field)
      end
    end

    def range(field, **range)
      range.compact!
      filter = {
        range: {
          field => range
        }
      }
      duped = self.dup
      duped.filters.push(filter)
      return duped
    end

    private

    def aggregation(aggregation_type, field)
      field = field.to_s
      query = Jbuilder.encode do |json|
        json.size 0
        json.aggs do
          json.set! field do
            json.set! aggregation_type do
              json.field field
            end
          end
        end
        json.filter build_filters() unless @filters.empty?
      end
      return search(query)["aggregations"][field]
    end

    def search(body)
      MetricsSpec.client.search(q: @query_string, body: body)
    end

    def build_filters
      return @filters.first if @filters.size == 1
      return Jbuilder.new {|json| json.and @filters }
    end
  end
end
