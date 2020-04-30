# frozen_string_literal: true

require 'spec_helper'

describe ProjectAccessToken do
  describe '.build' do
    let(:project_access_token) { build(:project_access_token) }

    it 'is a valid project access token' do
      expect(project_access_token).to be_valid
    end
  end

  context 'validations' do
    let(:project_access_token) { subject }

    it 'requires the presence of a personal access token' do
      
    end

    it 'requires the presence of a  project' do
      
    end

    it 'requires the presence of a user' do
      
    end
  end
end
