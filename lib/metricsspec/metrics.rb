module MetricsSpec
  class Metrics
    HostField = "@host"

    def initialize(query_string, host_field: nil)
      @query_string = query_string
      @filters = []
    end

    attr_reader :query_string, :aggs, :filters

    def initialize_copy(orig)
      @filters = orig.filters.dup
    end

    def [](field)
      Field.new(self, field)
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
      hits.map! {|hit| hit["_source"] }
      return hits.first if n == 1
      return hits
    end

    def empty?
      count.zero?
    end

    def term(field, term)
      filter = {
        term: {
          field => term
        }
      }
      return filtered(filter)
    end

    def range(field, **range)
      filter = {
        range: {
          field => range
        }
      }
      return filtered(filter)
    end

    DefaultHostField = "@host"
    DefaultTimeField = "@timestamp"

    def at(host, field: DefaultHostField)
      term(field, host)
    end

    def within(seconds, field: DefaultTimeField)
      range(field, gte: "now-#{seconds}s")
    end

    def aggs(aggregation_type, field, **options)
      field = field.to_s
      query = Jbuilder.encode do |json|
        json.size 0
        json.aggs do
          json.set! field do
            json.set! aggregation_type do
              json.field field
              json.merge! options unless options.empty?
            end
          end
        end
        json.filter build_filters() unless @filters.empty?
      end
      return search(query)["aggregations"][field]
    end

    private

    def search(body)
      MetricsSpec.client.search(q: @query_string, body: body)
    end

    def build_filters
      return @filters.first if @filters.size == 1
      return Jbuilder.new {|json| json.and @filters }
    end

    def filtered(filter)
      duped = self.dup
      duped.filters.push(filter)
      return duped
    end
  end
end
