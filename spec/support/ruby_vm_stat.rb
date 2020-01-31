# frozen_string_literal: true

# Usage:
#
# RUBY_VM_STAT=1 rspec spec/user_spec.rb
# RUBY_VM_STAT=verbose rspec spec/user_spec.rb
module RubyVmStat
  class Counter
    attr_reader :location, :before, :after, :diff

    def initialize(location)
      @location = location
      @before = RubyVM.stat
    end

    def stop
      raise 'Already stopped?' if @after

      @after = RubyVM.stat
      @diff = calc_diff

      self
    end

    def diff?
      diff.any?
    end

    def weight
      @diff.values.sum
    end

    def output
      "#{location}: #{diff}"
    end

    private

    def calc_diff
      diff = {}

      before.each do |key, value|
        n = after[key] - value
        diff[key] = n unless n.zero?
      end

      diff
    end
  end

  class Summary
    include Enumerable

    attr_reader :counters

    def initialize
      @counters = []
    end

    def add(counter)
      @counters << counter
    end

    def any?
      @counters.any?
    end

    def each(&block)
      @counters.sort_by(&:weight).each(&block)
    end
  end

  def self.track
    counter = Counter.new('eval')
    yield
  ensure
    counter.stop
    puts counter.output if counter.diff?
  end

  def self.for(config)
    summary = Summary.new
    verbose = ENV['RUBY_VM_STAT'] == 'verbose'

    config.around(:example) do |example|
      counter = Counter.new(example.location)

      example.run
    ensure
      counter.stop

      summary.add(counter) if counter.diff?

      if verbose && counter.diff?
        puts counter.output
      end
    end

    config.after(:suite) do
      if summary.any?
        puts <<~MSG

          Summary RubyVM.stat:
          -------------------
        MSG

        summary.each do |counter|
          puts counter.output
        end
      end
    end
  end
end
