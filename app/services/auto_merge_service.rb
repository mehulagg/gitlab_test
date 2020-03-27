# frozen_string_literal: true

class AutoMergeService < BaseService
  STRATEGY_MERGE_WHEN_PIPELINE_SUCCEEDS = 'merge_when_pipeline_succeeds'
  STRATEGIES = [STRATEGY_MERGE_WHEN_PIPELINE_SUCCEEDS].freeze

  class << self
    def all_strategies
      STRATEGIES
    end

    def get_service_class(strategy)
      return unless all_strategies.include?(strategy)

      "::AutoMerge::#{strategy.camelize}Service".constantize
    end
  end

  def execute(merge_request)
    return update(merge_request) if merge_request.auto_merge_enabled?

    strategy = strategy_for(merge_request)
    service = get_service_instance(strategy)

    unless service&.available_for?(merge_request)
      return error("The specified strategy '#{strategy}' is not available for the merge request")
    end

    service.execute(merge_request)
  end

  def process(merge_request)
    return unless merge_request.auto_merge_enabled?

    get_service_instance(merge_request.auto_merge_strategy).process(merge_request)
  end

  def cancel(merge_request)
    return error("Can't cancel the automatic merge", 406) unless merge_request.auto_merge_enabled?

    get_service_instance(merge_request.auto_merge_strategy).cancel(merge_request)
  end

  def abort(merge_request, reason)
    return error("Can't abort the automatic merge", 406) unless merge_request.auto_merge_enabled?

    get_service_instance(merge_request.auto_merge_strategy).abort(merge_request, reason)
  end

  def available_strategies(merge_request)
    self.class.all_strategies.select do |strategy|
      get_service_instance(strategy).available_for?(merge_request)
    end
  end

  def preferred_strategy(merge_request)
    available_strategies(merge_request).first
  end

  private

  def update(merge_request)
    get_service_instance(merge_request.auto_merge_strategy).update(merge_request)
  end

  def get_service_instance(strategy)
    self.class.get_service_class(strategy)&.new(project, current_user, params)
  end

  def strategy_for(merge_request)
    params[:auto_merge_strategy] || preferred_strategy(merge_request)
  end
end

AutoMergeService.prepend_if_ee('EE::AutoMergeService')
