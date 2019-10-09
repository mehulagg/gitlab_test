# frozen_string_literal: true

require 'sidekiq/api'

Sidekiq::Worker.extend ActiveSupport::Concern

module ApplicationWorker
  extend ActiveSupport::Concern

  include Sidekiq::Worker # rubocop:disable Cop/IncludeSidekiqWorker

  included do
    set_queue
  end

  class_methods do
    def perform_async(*args)
      debug_info(*args)
      set_sidekiq_profile_option

      super(*args)
    end

    def set_sidekiq_profile_option
      p "F" * 100
      p self.name
      sidekiq_options test_profile: 'test_profile'

      return unless self.name == Thread.current[:profile_sidekiq_worker]

      sidekiq_options profile: Thread.current[:profile_sidekiq_worker]

      p "B" * 100
      p "sidekiq_options set for profile"

      Thread.current[:profile_sidekiq_worker] = nil
    end

    def debug_info(*args)
      p "A" * 100
      p "Thread from ApplicationWorker.perform_async: #{Thread.current}"
      p Thread.current[:profile_sidekiq_worker]
      p "args: #{args}"
      p "Worker: #{self.name}"
      p "ancestors: #{self.ancestors}"
    end

    def inherited(subclass)
      subclass.set_queue
    end

    def set_queue
      queue_name = [queue_namespace, base_queue_name].compact.join(':')

      sidekiq_options queue: queue_name # rubocop:disable Cop/SidekiqOptionsQueue
    end

    def base_queue_name
      name
        .sub(/\AGitlab::/, '')
        .sub(/Worker\z/, '')
        .underscore
        .tr('/', '_')
    end

    def queue_namespace(new_namespace = nil)
      if new_namespace
        sidekiq_options queue_namespace: new_namespace

        set_queue
      else
        get_sidekiq_options['queue_namespace']&.to_s
      end
    end

    def queue
      get_sidekiq_options['queue'].to_s
    end

    def queue_size
      Sidekiq::Queue.new(queue).size
    end

    def bulk_perform_async(args_list)
      set_sidekiq_profile_option

      Sidekiq::Client.push_bulk('class' => self, 'args' => args_list)
    end

    def bulk_perform_in(delay, args_list)
      set_sidekiq_profile_option

      now = Time.now.to_i
      schedule = now + delay.to_i

      if schedule <= now
        raise ArgumentError, _('The schedule time must be in the future!')
      end

      Sidekiq::Client.push_bulk('class' => self, 'args' => args_list, 'at' => schedule)
    end
  end
end
