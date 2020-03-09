# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::MigratePushRules, :migration, schema: 2020_03_09_162730 do
  let(:push_rules) { table(:push_rules) }
  let(:project_push_rules) { table(:project_push_rules) }
  let(:projects) { table(:projects) }
  let(:namespace) { table(:namespaces).create(name: 'user', path: 'user') }

  subject { described_class.new }

  describe '#perform' do
    it 'creates new project push_rules for all push rules in the range' do
      projects.create(id: 1, namespace_id: namespace.id)
      projects.create(id: 2, namespace_id: namespace.id)
      projects.create(id: 3, namespace_id: namespace.id)
      push_rules.create(id: 5, is_sample: false, project_id: 1)
      push_rules.create(id: 7, is_sample: false, project_id: 2)
      push_rules.create(id: 8, is_sample: false, project_id: 3)

      subject.perform(5, 7)

      expect(project_push_rules.all.pluck(:project_id)).to contain_exactly(1, 2)
      expect(project_push_rules.all.pluck(:push_rule_id)).to contain_exactly(5, 7)
    end

    it 'creates new project push_rules for all push rules in the range that are connected to the project' do
      projects.create(id: 1, namespace_id: namespace.id)

      push_rules.create(id: 5, is_sample: true)
      push_rules.create(id: 7, is_sample: false, project_id: 1)

      subject.perform(5, 7)

      expect(project_push_rules.all.count).to eq(1)
      expect(project_push_rules.all.pluck(:project_id)).to contain_exactly(1)
      expect(project_push_rules.all.pluck(:push_rule_id)).to contain_exactly(7)
    end
  end
end
