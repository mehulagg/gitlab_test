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

    def counter_attribute(attribute)
      define_method("increment_#{attribute}") do |value|
        if success = counter_events.create(attribute_name: attribute, value: value)
          ConsolidateCountersWorker.perform_async(self.class.name, id, attribute)
        end

        success
      end

      define_method(attribute) do
        self[attribute] + counter_events_for(attribute).sum(:value)
      end

      # Disable setter method to ensure the attribute is read-only
      define_method("#{attribute}=") do |value|
        raise NoMethodError, "Attribute '#{attribute}' is read only"
      end
    end
  end

  # This method must only be called by ConsolidateCountersWorker
  # because it should run asynchronously and with exclusive lease.
  # TODO: Add specs for this.
  def slow_consolidate_counter_attribute!(attribute)
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("LOCK TABLE #{counter_events_table_name} IN EXCLUSIVE MODE")

      events = counter_events_for(attribute).to_a
      delta = events.sum(&:value)
      update_column(attribute, delta)
      counter_events.where(id: events).delete_all
    end
  end

  private

  def counter_events_table_name
    self.class.events_class.table_name
  end

  def counter_events_for(attribute)
    counter_events.where(attribute_name: attribute)
  end
end
