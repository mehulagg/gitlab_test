# frozen_string_literal: true

require 'sidekiq/api'

Sidekiq::Worker.extend ActiveSupport::Concern

module ApplicationWorker
  extend ActiveSupport::Concern

  include Sidekiq::Worker # rubocop:disable Cop/IncludeSidekiqWorker
  include WorkerAttributes

  included do
    set_queue
  end

  class_methods do
    def inherited(subclass)
      subclass.set_queue
    end

    def perform_async(*args)
      set_sidekiq_profile_option(jid, profile_option) do
        super(*args)
      end
    end

    def parse_sidekiq_profile_option
      profile_option = nil

      if Gitlab::SafeRequestStore[:sidekiq_profile_mode] && Gitlab::SafeRequestStore[:sidekiq_profile_worker] && self.name == Gitlab::SafeRequestStore[:sidekiq_profile_worker]
        profile_option = { mode: Gitlab::SafeRequestStore[:sidekiq_profile_mode], worker: Gitlab::SafeRequestStore[:sidekiq_profile_worker] }
      end

      profile_option
    end

    SIDEKIQ_PROFILE_KEY = 'sidekiq-profile:%s'
    DEFAULT_EXPIRATION = 30.minutes.to_i

    def set_sidekiq_profile_option(expire = DEFAULT_EXPIRATION)
      jid_or_jids = yield

      profile_option = parse_sidekiq_profile_option
      return jid_or_jids unless profile_option

      jids = jid_or_jids.is_a?(Array)? jid_or_jids: [ jid_or_jids ]

      jids.each do |jid|
        redis.set(sidekiq_profile_key_for(jid_or_jids), profile_option.to_json, ex: expire)
        p "qingyudebug: set_sidekiq_profile_option happened!"
        Rails.logger.error('qingyudebug: set_sidekiq_profile_option happened!')
      end

      Rails.logger.error( "qingyudebug: jid_or_jids: #{jid_or_jids}")
      p "qingyudebug: jid_or_jids"
      p jid_or_jids

      jid_or_jids
    end

    def sidekiq_profile_key_for(jid)
      SIDEKIQ_PROFILE_KEY % jid
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
      set_sidekiq_profile_option do
        Sidekiq::Client.push_bulk('class' => self, 'args' => args_list)
      end
    end

    def bulk_perform_in(delay, args_list)
      now = Time.now.to_i
      schedule = now + delay.to_i

      if schedule <= now
        raise ArgumentError, _('The schedule time must be in the future!')
      end

      set_sidekiq_profile_option do
        Sidekiq::Client.push_bulk('class' => self, 'args' => args_list, 'at' => schedule)
      end
    end
  end
end
