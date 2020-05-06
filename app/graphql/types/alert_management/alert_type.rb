# frozen_string_literal: true

module Types
  module AlertManagement
    class AlertType < BaseObject
      graphql_name 'AlertManagementAlert'
      description "Describes an alert from the project's Alert Management"

      authorize :read_alert_management_alerts

      field :iid,
            GraphQL::ID_TYPE,
            null: false,
            description: 'Internal ID of the alert'

      field :title,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Title of the alert'

      field :severity,
            AlertManagement::SeverityEnum,
            null: true,
            description: 'Severity of the alert'

      field :status,
            AlertManagement::StatusEnum,
            null: true,
            description: 'Status of the alert'

      field :service,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Service the alert came from'

      field :monitoring_tool,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Monitoring tool the alert came from'

      field :event_count,
            GraphQL::INT_TYPE,
            null: true,
            description: 'Number of events of this alert',
            method: :events

      field :payload,
            GraphQL::Types::JSON,
            description: 'Raw payload of the alert',
            null: true

      field :description,
            GraphQL::STRING_TYPE,
            description: 'Description of the alert',
            null: true

      field :hosts,
            [GraphQL::STRING_TYPE],
            description: 'Hosts the alert was raised on',
            null: true

      field :started_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the alert was raised'

      field :ended_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the alert ended'

      field :created_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the alert was created'

      field :updated_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the alert was last updated'
    end
  end
end
