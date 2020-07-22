# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::IncidentsHelper do
  include Gitlab::Routing.url_helpers

  let(:project) { create(:project) }
  let(:project_path) { project.full_path }
  let(:incident_id) { 1 }

  describe '#incidents_data' do
    subject(:data) { helper.incidents_data(project) }

    it 'returns frontend configuration' do
      expect(data).to match('project-path' => project_path)
    end
  end

  describe '#incident_detail_data' do
    subject(:data) { helper.incident_detail_data(project, incident_id) }

    it 'returns frontend configuration' do
      expect(data).to match('project-path' => project_path, 'incident-id' => incident_id)
    end
  end
end
