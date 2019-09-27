# frozen_string_literal: true

# TODO: write class description
# ensure to document that each time this is used for a new class
# we need to create a db migration to add the new *_events table
module CounterAttribute
  extend ActiveSupport::Concern

  included do |base|
    base.class_eval do
      @events_class = "#{base}Event".constantize

      has_many :counter_events, class_name: "#{@events_class}"
    end
  end

  class_methods do
    attr_reader :events_class

    def counter_attribute(name)
      define_method("increment_#{name}") do |value|
        if success = counter_events.create(attribute_name: name, value: value)
          # TODO: uncomment this
          # ConsolidateCountersWorker.perform_async(self.class.name, id, name)
        end

        success
      end

      define_method(name) do
        # TODO: read all values with a single query
        self[name] + counter_events.where(attribute_name: name).sum(:value)
      end

      # Disable setter method to ensure the attribute is read-only
      define_method("#{name}=") do |value|
        raise NoMethodError, "Attribute '#{name}' is read only"
      end
    end
  end
end
