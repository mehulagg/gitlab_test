# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlobPresenter, :seed_helper do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:repository) { project.repository }

  let(:blob) { repository.blob_at('HEAD', 'files/ruby/regex.rb') }

  subject(:presenter) { described_class.new(blob) }

  describe '.web_url' do
    let(:blob) { Gitlab::Graphql::Representation::TreeEntry.new(repository.tree.blobs.first, repository) }

    it { expect(presenter.web_url).to eq("http://localhost/#{project.full_path}/-/blob/#{blob.commit_id}/#{blob.path}") }
  end

  describe '#web_path' do
    let(:project) { create(:project, :repository) }
    let(:repository) { project.repository }
    let(:blob) { Gitlab::Graphql::Representation::TreeEntry.new(repository.tree.blobs.first, repository) }

    subject { described_class.new(blob) }

    it { expect(subject.web_path).to eq("/#{project.full_path}/-/blob/#{blob.commit_id}/#{blob.path}") }
  end

  describe '#highlight' do
    it 'returns highlighted content' do
      expect(Gitlab::Highlight).to receive(:highlight).with('files/ruby/regex.rb', blob.data, plain: nil, language: nil)

      presenter.highlight
    end

    it 'returns plain content when :plain is true' do
      expect(Gitlab::Highlight).to receive(:highlight).with('files/ruby/regex.rb', blob.data, plain: true, language: nil)

      presenter.highlight(plain: true)
    end

    context '"to" param is present' do
      before do
        allow(blob)
          .to receive(:data)
          .and_return("line one\nline two\nline 3")
      end

      it 'returns limited highlighted content' do
        expect(Gitlab::Highlight).to receive(:highlight).with('files/ruby/regex.rb', "line one\n", plain: nil, language: nil)

        presenter.highlight(to: 1)
      end
    end

    context 'gitlab-language contains a match' do
      before do
        allow(blob).to receive(:language_from_gitattributes).and_return('ruby')
      end

      it 'passes language to inner call' do
        expect(Gitlab::Highlight).to receive(:highlight).with('files/ruby/regex.rb', blob.data, plain: nil, language: 'ruby')

        presenter.highlight
      end
    end
  end
end
