# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::ProjectSettings do
  subject { build :compliance_framework_project_setting }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:framework) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:project) }

    it 'confirms that the framework is unique for the project' do
      expect(subject).to validate_uniqueness_of(:framework).scoped_to(:project_id).ignoring_case_sensitivity
    end
  end
end
