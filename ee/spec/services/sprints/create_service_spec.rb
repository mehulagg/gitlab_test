# frozen_string_literal: true

require 'spec_helper'

describe Sprints::CreateService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  describe '#execute' do
    context "valid params" do
      before do
        project.add_maintainer(user)

        opts = {
            title: 'v2.1.9',
            description: 'Patch release to fix security issue'
        }

        @sprint = described_class.new(project, user, opts).execute
      end

      it { expect(@sprint).to be_valid }
      it { expect(@sprint.title).to eq('v2.1.9') }
    end
  end
end
