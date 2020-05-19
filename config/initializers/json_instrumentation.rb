# frozen_string_literal: true

module JSON
  class << self
    %i(parse parse! dump generate pretty_generate).each do |method|
      uninstrumented_method = :"#{method}_uninstrumented"
      alias_method uninstrumented_method, method

      define_method(method) do |*args|
        instrument_method(method) do
          send(uninstrumented_method, *args)
        end
      end
    end

    private

    def instrument_method(method_name)
      response = nil
      time = Benchmark.realtime { response = yield }
      histogram = Gitlab::Metrics.histogram(
        :gitlab_json_method_seconds,
        "Time taken in various JSON methods"
      )

      histogram.observe(
        { method: method_name.to_s },
        time
      )

      puts "JSON execution time: #{time}"

      response
    end
  end
end
