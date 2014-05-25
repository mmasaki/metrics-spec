module MetricsSpec
  class Field
    def initialize(metrics, field)
      @metrics = metrics
      @field = field.freeze
    end

    def inspect
      "#<#{self.class.name}:\"#{@field}\" metrics=#{@metrics.inspect}>"
    end

    SingleValueAggs = [:min, :max, :sum, :avg, :value_count, :cardinality].freeze
    SingleValueAggs.each do |aggregation_type|
      define_method(aggregation_type) do
        return @metrics.aggs(aggregation_type, @field)["value"]
      end
    end

    MultiValueAggs = [:stats, :extended_stats, :percentiles].freeze
    MultiValueAggs.each do |aggregation_type, **options|
      define_method(aggregation_type) do
        return @metrics.aggs(aggregation_type, @field)
      end
    end

    def last(n=1)
      hits = @metrics.last(n)
      case hits
      when Hash
        hits[@field]
      when Array
        hits.map {|hit| hit[@field] }
      end
    end

    def minmax
      stats = stats()
      return stats["min"], stats["max"]
    end
  end
end
