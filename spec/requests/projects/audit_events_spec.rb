# frozen_string_literal: true

require 'spec_helper'

describe 'view audit events' do
  describe 'GET /:namespace/:project/-/audit_evetns' do
    let_it_be(:project) { create(:project, :repository) }
    let_it_be(:user) { project.owner }
    let_it_be(:audit_event) { create(:audit_event, :project_event, entity_id: project.id) }

    let(:send_request!) do
      get namespace_project_audit_events_path(namespace_id: project.namespace, project_id: project)
    end

    before do
      project.add_developer(user)
      login_as(user)
    end

    it 'avoids N+1 DB queries', :request_store do
      control = ActiveRecord::QueryRecorder.new(skip_cached: false) { send_request! }.count

      create_list(:audit_event, 2, :project_event, entity_id: project.id)

      expect do
        send_request!
      end.not_to exceed_all_query_limit(control)
    end
  end
end
