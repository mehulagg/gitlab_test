# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::GitAccessSnippetDelegator do
  let(:actor) { build_stubbed(:user) }
  let(:result) { double(:result) }

  subject { described_class.new(actor, snippet, 'ssh', authentication_abilities: []) }

  describe '#check' do
    shared_examples 'delegation' do
      it 'delegates to project snippet checker' do
        expect_next_instance_of(checker_class, actor, snippet, 'ssh', authentication_abilities: []) do |checker|
          allow(checker).to receive(:check).and_return(result)
        end

        expect(subject.check).to eq(result)
      end
    end

    context 'personal snippet' do
      let(:snippet) { build_stubbed(:personal_snippet) }
      let(:checker_class) { Gitlab::GitAccessPersonalSnippet }

      it_behaves_like('delegation')
    end

    context 'project snippet' do
      let(:snippet) { build_stubbed(:project_snippet) }
      let(:checker_class) { Gitlab::GitAccessProjectSnippet }

      it_behaves_like('delegation')
    end
  end
end
