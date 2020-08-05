# frozen_string_literal: true

require_dependency 'alert_management'

module AlertManagement
  class Alert < ApplicationRecord
    include IidRoutes
    include AtomicInternalId
    include ShaAttribute
    include Sortable
    include Noteable
    include Gitlab::SQL::Pattern
    include Presentable

    STATUSES = {
      triggered: 0,
      acknowledged: 1,
      resolved: 2,
      ignored: 3
    }.freeze

    STATUS_EVENTS = {
      triggered: :trigger,
      acknowledged: :acknowledge,
      resolved: :resolve,
      ignored: :ignore
    }.freeze

    OPEN_STATUSES = [
      :triggered,
      :acknowledged
    ].freeze

    DETAILS_IGNORED_PARAMS = %w(start_time).freeze

    belongs_to :project
    belongs_to :issue, optional: true
    belongs_to :prometheus_alert, optional: true
    belongs_to :environment, optional: true

    has_many :alert_assignees, inverse_of: :alert
    has_many :assignees, through: :alert_assignees

    has_many :notes, as: :noteable, inverse_of: :noteable, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent
    has_many :ordered_notes, -> { fresh }, as: :noteable, class_name: 'Note'
    has_many :user_mentions, class_name: 'AlertManagement::AlertUserMention', foreign_key: :alert_management_alert_id

    has_internal_id :iid, scope: :project, init: ->(s) { s.project.alert_management_alerts.maximum(:iid) }

    sha_attribute :fingerprint

    HOSTS_MAX_LENGTH = 255

    validates :title,           length: { maximum: 200 }, presence: true
    validates :description,     length: { maximum: 1_000 }
    validates :service,         length: { maximum: 100 }
    validates :monitoring_tool, length: { maximum: 100 }
    validates :project,         presence: true
    validates :events,          presence: true
    validates :severity,        presence: true
    validates :status,          presence: true
    validates :started_at,      presence: true
    validates :fingerprint,     allow_blank: true, uniqueness: {
      scope: :project,
      conditions: -> { not_resolved },
      message: -> (object, data) { _('Cannot have multiple unresolved alerts') }
    }, unless: :resolved?
    validate :hosts_length

    enum severity: {
      critical: 0,
      high: 1,
      medium: 2,
      low: 3,
      info: 4,
      unknown: 5
    }

    state_machine :status, initial: :triggered do
      state :triggered, value: STATUSES[:triggered]

      state :acknowledged, value: STATUSES[:acknowledged]

      state :resolved, value: STATUSES[:resolved] do
        validates :ended_at, presence: true
      end

      state :ignored, value: STATUSES[:ignored]

      state :triggered, :acknowledged, :ignored do
        validates :ended_at, absence: true
      end

      event :trigger do
        transition any => :triggered
      end

      event :acknowledge do
        transition any => :acknowledged
      end

      event :resolve do
        transition any => :resolved
      end

      event :ignore do
        transition any => :ignored
      end

      before_transition to: [:triggered, :acknowledged, :ignored] do |alert, _transition|
        alert.ended_at = nil
      end

      before_transition to: :resolved do |alert, transition|
        ended_at = transition.args.first
        alert.ended_at = ended_at || Time.current
      end
    end

    delegate :iid, to: :issue, prefix: true, allow_nil: true
    delegate :metrics_dashboard_url, :runbook, to: :present

    scope :for_iid, -> (iid) { where(iid: iid) }
    scope :for_status, -> (status) { where(status: status) }
    scope :for_fingerprint, -> (project, fingerprint) { where(project: project, fingerprint: fingerprint) }
    scope :for_environment, -> (environment) { where(environment: environment) }
    scope :search, -> (query) { fuzzy_search(query, [:title, :description, :monitoring_tool, :service]) }
    scope :open, -> { with_status(OPEN_STATUSES) }
    scope :not_resolved, -> { where.not(status: STATUSES[:resolved]) }
    scope :with_prometheus_alert, -> { includes(:prometheus_alert) }

    scope :order_start_time,    -> (sort_order) { order(started_at: sort_order) }
    scope :order_end_time,      -> (sort_order) { order(ended_at: sort_order) }
    scope :order_event_count,   -> (sort_order) { order(events: sort_order) }

    # Ascending sort order sorts severity from less critical to more critical.
    # Descending sort order sorts severity from more critical to less critical.
    # https://gitlab.com/gitlab-org/gitlab/-/issues/221242#what-is-the-expected-correct-behavior
    scope :order_severity,      -> (sort_order) { order(severity: sort_order == :asc ? :desc : :asc) }

    # Ascending sort order sorts statuses: Ignored > Resolved > Acknowledged > Triggered
    # Descending sort order sorts statuses: Triggered > Acknowledged > Resolved > Ignored
    # https://gitlab.com/gitlab-org/gitlab/-/issues/221242#what-is-the-expected-correct-behavior
    scope :order_status,        -> (sort_order) { order(status: sort_order == :asc ? :desc : :asc) }

    scope :counts_by_status, -> { group(:status).count }
    scope :counts_by_project_id, -> { group(:project_id).count }

    alias_method :state, :status_name

    def self.sort_by_attribute(method)
      case method.to_s
      when 'started_at_asc'     then order_start_time(:asc)
      when 'started_at_desc'    then order_start_time(:desc)
      when 'ended_at_asc'       then order_end_time(:asc)
      when 'ended_at_desc'      then order_end_time(:desc)
      when 'event_count_asc'    then order_event_count(:asc)
      when 'event_count_desc'   then order_event_count(:desc)
      when 'severity_asc'       then order_severity(:asc)
      when 'severity_desc'      then order_severity(:desc)
      when 'status_asc'         then order_status(:asc)
      when 'status_desc'        then order_status(:desc)
      else
        order_by(method)
      end
    end

    def self.last_prometheus_alert_by_project_id
      ids = select(arel_table[:id].maximum).group(:project_id)
      with_prometheus_alert.where(id: ids)
    end

    def details
      details_payload = payload.except(*attributes.keys, *DETAILS_IGNORED_PARAMS)

      Gitlab::Utils::InlineHash.merge_keys(details_payload)
    end

    def prometheus?
      monitoring_tool == Gitlab::AlertManagement::AlertParams::MONITORING_TOOLS[:prometheus]
    end

    def register_new_event!
      increment!(:events)
    end

    # required for todos (typically contains an identifier like issue iid)
    #  no-op; we could use iid, but we don't have a reference prefix
    def to_reference(_from = nil, full: false)
      ''
    end

    def execute_services
      return unless project.has_active_services?(:alert_hooks)

      project.execute_services(hook_data, :alert_hooks)
    end

    def present
      return super(presenter_class: AlertManagement::PrometheusAlertPresenter) if prometheus?

      super
    end

    private

    def hook_data
      Gitlab::DataBuilder::Alert.build(self)
    end

    def hosts_length
      return unless hosts

      errors.add(:hosts, "hosts array is over #{HOSTS_MAX_LENGTH} chars") if hosts.join.length > HOSTS_MAX_LENGTH
    end
  end
end
