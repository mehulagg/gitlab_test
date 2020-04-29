# frozen_string_literal: true

require 'spec_helper'

describe ContainerBaseService do
  let(:project) { Project.new }
  let(:user) { User.new }

  describe '#initialize' do
    it 'accepts container' do
      subject = described_class.new(project)

      expect(subject.project).to eq(project)
    end

    it 'accepts user' do
      subject = described_class.new(project, user)

      expect(subject.current_user).to eq(user)
    end
  end
end
