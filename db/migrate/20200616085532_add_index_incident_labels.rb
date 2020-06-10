# frozen_string_literal: true

class AddIndexIncidentLabels < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_incident_labels'

  # Inlined from `IncidentManagement::CreateIncidentLabelService::LABEL_PROPERTIES`
  INCIDENT_LABEL = {
    title: 'incident',
    color: '#CC0033',
    description: <<~DESCRIPTION.chomp
      Denotes a disruption to IT services and \
      the associated issues require immediate attention
    DESCRIPTION
  }.freeze

  disable_ddl_transaction!

  def up
    where = INCIDENT_LABEL.map { |key, value| "#{key}='#{value}'" }.join(' AND ')
    add_concurrent_index :labels, :id, where: where, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :labels, INDEX_NAME
  end
end
