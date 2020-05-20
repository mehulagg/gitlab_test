# frozen_string_literal: true

require 'spec_helper'

describe ProjectServicesWithInheritance do
  describe '#all' do
    subject { described_class.new(project).all }

    let(:project) { create(:project, group: group) }
    let(:group) { create(:group) }
    let!(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: 'project@example.com' }) }

    it 'returns one service with project level settings', :aggregate_failures do
      expect(subject.count).to eq(1)
      expect(subject.first.recipients).to eq('project@example.com')
    end

    context 'with group_level service' do
      let!(:group_level_service) { create(:emails_on_push_service, group: group, properties: { recipients: 'group@example.com' }) }

      context 'without project level overwrite' do
        let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: nil }) }

        it 'returns one service with group level settings', :aggregate_failures do
          expect(subject.count).to eq(1)
          expect(subject.first.recipients).to eq('group@example.com')
        end
      end

      context 'with project_level overwrite' do
        let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: 'project@example.com' }) }

        it 'overrides the group level service and returns project level settings', :aggregate_failures do
          expect(subject.count).to eq(1)
          expect(subject.first.recipients).to eq('project@example.com')
        end
      end

      context 'with more group levels' do
        let(:group) { create(:group, parent: parent_group) }
        let(:parent_group) { create(:group) }
        let!(:parent_group_level_service) { create(:emails_on_push_service, group: parent_group, properties: { recipients: 'parent_group@example.com' }) }

        context 'without lower group level and project overwrite' do
          let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: nil }) }
          let(:group_level_service) { create(:emails_on_push_service, group: group, properties: { recipients: nil }) }

          it 'inherits from the parent group level service', :aggregate_failures do
            expect(subject.count).to eq(1)
            expect(subject.first.recipients).to eq('parent_group@example.com')
          end
        end

        context 'with group_level overwrite' do
          let!(:group_level_service) { create(:emails_on_push_service, group: group, properties: { recipients: 'group@example.com' }) }
          let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: nil }) }

          it 'overrides the parent group level service', :aggregate_failures do
            expect(subject.count).to eq(1)
            expect(subject.first.recipients).to eq('group@example.com')
          end

          context 'and with project_level overwrite' do
            let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: 'project@example.com' }) }

            it 'overrides the parent group level service', :aggregate_failures do
              expect(subject.count).to eq(1)
              expect(subject.first.recipients).to eq('project@example.com')
            end
          end
        end

        context 'instance level service' do
          let!(:instance_level_service) { create(:emails_on_push_service, :instance, recipients: 'instance@example.com') }
          let!(:parent_group_level_service) { create(:emails_on_push_service, group: parent_group, properties: { recipients: nil }) }

          context 'without overwriting group or project services' do
            let(:parent_group_level_service) { create(:emails_on_push_service, group: parent_group, properties: { recipients: nil }) }
            let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: nil }) }
            let(:group_level_service) { create(:emails_on_push_service, group: group, properties: { recipients: nil }) }

            it 'inherits from the instance level service', :aggregate_failures do
              expect(subject.count).to eq(1)
              expect(subject.first.recipients).to eq('instance@example.com')
            end
          end

          context 'with parent_group_level overwide' do
            let!(:parent_group_level_service) { create(:emails_on_push_service, group: parent_group, properties: { recipients: 'parent_group@example.com' }) }
            let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: nil }) }
            let(:group_level_service) { create(:emails_on_push_service, group: group, properties: { recipients: nil }) }

            it 'inherits from the parent group level service', :aggregate_failures do
              expect(subject.count).to eq(1)
              expect(subject.first.recipients).to eq('parent_group@example.com')
            end

            context 'and with group_level overwrite' do
              let!(:group_level_service) { create(:emails_on_push_service, group: group, properties: { recipients: 'group@example.com' }) }
              let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: nil }) }

              it 'inherits from the group level service', :aggregate_failures do
                expect(subject.count).to eq(1)
                expect(subject.first.recipients).to eq('group@example.com')
              end

              context 'and with project_level overwrite' do
                let(:project_level_service) { create(:emails_on_push_service, project: project, properties: { recipients: 'project@example.com' }) }

                it 'inherits from the project level service', :aggregate_failures do
                  expect(subject.count).to eq(1)
                  expect(subject.first.recipients).to eq('project@example.com')
                end
              end
            end
          end
        end
      end
    end
  end

  describe '#all_with_ancestors' do
    subject { described_class.new(project).all_with_ancestors }

    let!(:project_level_service) { create(:emails_on_push_service, project: project) }
    let(:project) { create(:project) }

    context 'with only project_level service' do
      it 'returns only the project level service', :aggregate_failures do
        expect(subject.count).to eq(1)
        expect(subject.pluck(:id)).to contain_exactly(project_level_service.id)
      end
    end

    context 'with group_level service' do
      let(:project) { create(:project, group: group) }
      let(:group) { create(:group) }
      let!(:group_level_service) { create(:emails_on_push_service, group: group) }

      it 'returns all levels of services', :aggregate_failures do
        expect(subject.count).to eq(2)
        expect(subject.pluck(:id)).to contain_exactly(project_level_service.id, group_level_service.id)
      end

      context 'with more group levels' do
        let(:group) { create(:group, parent: parent_group) }
        let(:parent_group) { create(:group) }
        let!(:parent_group_level_service) { create(:emails_on_push_service, group: parent_group) }

        it 'returns all levels of services', :aggregate_failures do
          expect(subject.count).to eq(3)
          expect(subject.pluck(:id)).to contain_exactly(project_level_service.id, group_level_service.id, parent_group_level_service.id)
        end

        context 'And instance level service' do
          let!(:instance_level_service) { create(:emails_on_push_service, :instance) }

          it 'returns all levels of services', :aggregate_failures do
            expect(subject.count).to eq(4)
            expect(subject.pluck(:id)).to contain_exactly(project_level_service.id, group_level_service.id, parent_group_level_service.id, instance_level_service.id)
          end
        end
      end
    end
  end

  describe '#hooks' do
    subject { described_class.new(project).hooks(scope) }

    let(:project) { create(:project, group: group) }
    let(:group) { create(:group) }

    context 'issue hooks' do
      let(:scope) { 'issue_hooks' }

      it { is_expected.to eq([]) }

      context 'with issue_hooks activated services' do
        let!(:slack_service) { create(:slack_service, issues_events: true, project: project) }

        specify do
          expect(subject.pluck(:id)).to contain_exactly(slack_service.id)
        end

        context 'and inherited issue_hooks' do
          let!(:emails_on_push_service) { create(:emails_on_push_service, project: project, issues_events: nil, push_events: false) }
          let!(:group_emails_on_push_service) { create(:emails_on_push_service, group: group, issues_events: true) }

          specify do
            expect(subject.pluck(:id)).to contain_exactly(slack_service.id, emails_on_push_service.id)
          end
        end
      end
    end

    context 'push hooks' do
      let(:scope) { 'push_hooks' }

      it { is_expected.to eq([]) }

      context 'with push_hooks activated services' do
        let!(:slack_service) { create(:slack_service, push_events: true, project: project) }
        let!(:emails_on_push_service) { create(:emails_on_push_service, project: project, push_events: true) }

        specify do
          expect(subject.pluck(:id)).to contain_exactly(slack_service.id, emails_on_push_service.id)
        end

        context 'and inherited push_hooks' do
          let!(:emails_on_push_service) { create(:emails_on_push_service, project: project, push_events: nil) }
          let!(:group_emails_on_push_service) { create(:emails_on_push_service, group: group, push_events: true) }

          specify do
            expect(subject.pluck(:id)).to contain_exactly(slack_service.id, emails_on_push_service.id)
          end
        end
      end
    end
  end
end
