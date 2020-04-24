# frozen_string_literal: true

require 'spec_helper'

describe Sprints::DestroyService do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:sprint) { create(:sprint, title: 'Sprint v1.0', project: project) }

  before do
    project.add_maintainer(user)
  end

  def service
    described_class.new(project, user, {})
  end

  describe '#execute' do
    it 'deletes sprint' do
      service.execute(sprint)

      expect { sprint.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes sprint id from issuables' do
      issue = create(:issue, project: project, sprint: sprint)
      merge_request = create(:merge_request, source_project: project, sprint: sprint)

      service.execute(sprint)

      expect(issue.reload.sprint).to be_nil
      expect(merge_request.reload.sprint).to be_nil
    end

    it 'logs destroy event' do
      service.execute(sprint)

      event = Event.where(project_id: sprint.project_id, target_type: 'Sprint')

      expect(event.count).to eq(1)
    end

    context 'group sprints' do
      let(:group) { create(:group) }
      let(:group_sprint) { create(:sprint, group: group) }

      before do
        project.update(namespace: group)
        group.add_developer(user)
      end

      it { expect(service.execute(group_sprint)).to eq(group_sprint) }

      it 'deletes sprint id from issuables' do
        issue = create(:issue, project: project, sprint: group_sprint)
        merge_request = create(:merge_request, source_project: project, sprint: group_sprint)

        service.execute(group_sprint)

        expect(issue.reload.sprint).to be_nil
        expect(merge_request.reload.sprint).to be_nil
      end

      it 'does not log destroy event' do
        expect { service.execute(group_sprint) }.not_to change { Event.count }
      end
    end
  end
end
