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

  SIDEKIQ_PROFILE_KEY = 'sidekiq-profile:%s'
  DEFAULT_EXPIRATION_MINUTES = 30.minutes.to_i

  class_methods do
    def inherited(subclass)
      subclass.set_queue
    end

    def perform_async(*args)
     # binding.pry
      Rails.logger.error( "qingyudebug: enter perform_async, with args: #{args},  Worker: #{self.name}")
      set_sidekiq_profile_option do
        super(*args)
      end
    end

    def parse_sidekiq_profile_option
      profile_option = nil

      profile_mode = Gitlab::SafeRequestStore[:sidekiq_profile_mode]
      profile_worker = Gitlab::SafeRequestStore[:sidekiq_profile_worker]

      if profile_mode && profile_worker && self.name == profile_worker
        profile_option = { mode: profile_mode, worker: profile_worker }
      end

      profile_option
    end

    def set_sidekiq_profile_option(expire = DEFAULT_EXPIRATION_MINUTES)
      Rails.logger.error( "qingyudebug: enter set_sidekiq_profile_option,   Worker: #{self.name}")
      jid_or_jids = yield
      Rails.logger.error( "qingyudebug: after yield jid_or_jids: #{jid_or_jids},   Worker: #{self.name}")


      profile_option = parse_sidekiq_profile_option
      Rails.logger.error( "qingyudebug: after parse_sidekiq_profile_option:  profile_option: #{profile_option},   Worker: #{self.name}")

      if profile_option
        jids = Array(jid_or_jids)

        jids.each do |jid|
          ::Gitlab::Redis::SharedState.with do |redis|
            redis.set(sidekiq_profile_key_for(jid), profile_option.to_json, ex: expire)
          end
          Rails.logger.error("qingyudebug: set_sidekiq_profile_option happened! Worker: #{self.name}, key: #{sidekiq_profile_key_for(jid_or_jids)}, value: #{profile_option.to_json}, expire: #{expire} ")
        end
      else
        Rails.logger.error("qingyudebug: profile option not found for this worker #{self.name}, did not set redis key")
      end

      Rails.logger.error( "qingyudebug: jid_or_jids will return from set_sidekiq_profile_option: #{jid_or_jids}")

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
      Rails.logger.error( "qingyudebug: enter bulk_perform_async, with args_list: #{args_list},  Worker: #{self.name}")
      set_sidekiq_profile_option do
        Sidekiq::Client.push_bulk('class' => self, 'args' => args_list)
      end
    end

    def bulk_perform_in(delay, args_list)
      Rails.logger.error( "qingyudebug: enter bulk_perform_async, with args_list: #{args_list},  Worker: #{self.name}")

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
