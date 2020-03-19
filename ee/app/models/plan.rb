# frozen_string_literal: true

class Plan < ApplicationRecord
  DEFAULT = 'default'.freeze
  FREE = 'free'.freeze
  GOLD = 'gold'.freeze # This is hack needed to support `group.rb`

  class Metadata
    attr_reader :name, :hosted, :paid, :license

    def initialize(name, hosted: false, paid: false, license: nil)
      @name = name
      @hosted = hosted
      @paid = paid
      @license = license
    end
  end

  # keep ordered by tier
  METADATA = [
    Metadata.new('default'),
    Metadata.new('free'),
    Metadata.new('early_adopter', hosted: true, license: License::EARLY_ADOPTER_PLAN),
    Metadata.new('bronze', hosted: true, paid: true, license: License::STARTER_PLAN),
    Metadata.new('silver', hosted: true, paid: true, license: License::PREMIUM_PLAN),
    Metadata.new('gold', hosted: true, paid: true, license: License::ULTIMATE_PLAN)
  ]

  PLANS = METADATA.map { |plan| [plan.name, plan] }.to_h.freeze
  PLAN_NAMES = PLANS.keys.freeze

  # This constant must keep ordered by tier.
  PAID_HOSTED_PLAN_NAMES = METADATA.select(&:paid).select(&:hosted).map(&:name).freeze
  PAID_PLAN_NAMES = METADATA.select(&:paid).map(&:name).freeze
  HOSTED_PLAN_NAMES = METADATA.select(&:hosted).map(&:name).freeze

  has_many :namespaces
  has_many :hosted_subscriptions, class_name: 'GitlabSubscription', foreign_key: 'hosted_plan_id'
  has_one :limits, class_name: 'PlanLimits'

  enum name: PLAN_NAMES, _suffix: :level

  scope :with_feature, -> (feature) { where(name: plans_with_feature(feature)) }
  scope :with_paid_plans, -> { where(name: PAID_PLAN_NAMES) }
  scope :with_hosted_plans, -> { where(name: HOSTED_PLAN_NAMES) }

  def self.plans_with_feature(feature)
    # this returns license plans, like: `starter`
    licenses = License.plans_with_feature(feature)

    # we look for plans with a given license
    PLANS.select { |plan_name, plan_metadata| licenses.include?(plan_metadata[:license]) }.keys
  end

  def self.free_or_default
    free || default
  end

  def self.default
    Gitlab::SafeRequestStore.fetch(:plan_default) { find_or_initialize_by(name: DEFAULT) }
  end

  def self.free
    return unless Gitlab.com?

    Gitlab::SafeRequestStore.fetch(:plan_free) { find_by(name: FREE) }
  end

  def self.hosted_plans_for_namespaces(namespaces)
    namespaces = Array(namespaces)

    Plan
      .joins(:hosted_subscriptions)
      .with_hosted_plans
      .where(gitlab_subscriptions: { namespace_id: namespaces })
      .distinct
  end

  def metadata
    self.class.METADATA_BY_NAME.fetch(name)
  end

  def is_free?
    !is_paid?
  end

  def is_paid?
    metadata.fetch(:paid, false)
  end

  def is_hosted?
    metadata.fetch(:hosted, false)
  end

  def is_highest_tier?
    self.class.PLANS.last == metadata
  end
end
