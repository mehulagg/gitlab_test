# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Blob do
  include FakeBlobHelpers

  using RSpec::Parameterized::TableSyntax

  let(:project) { build(:project) }
  let(:personal_snippet) { build(:personal_snippet) }
  let(:project_snippet) { build(:project_snippet, project: project) }

  let(:repository) { project.repository }
  let(:lfs_enabled) { true }

  before do
    allow(repository).to receive(:lfs_enabled?) { lfs_enabled }
  end

  describe '.decorate' do
    it 'returns NilClass when given nil' do
      expect(described_class.decorate(nil, repository: repository)).to be_nil
    end
  end

  describe '.lazy' do
    let(:commit_id) { 'e63f41fe459e62e1228fcef60d7189127aeba95a' }
    let(:blob_size_limit) { 10 * 1024 * 1024 }

    shared_examples '.lazy checks' do
      it 'does not fetch blobs when none are accessed' do
        expect(repository).not_to receive(:blobs_at)

        described_class.lazy(commit_id, 'CHANGELOG', repository: repository)
      end

      it 'fetches all blobs for the same repository when one is accessed' do
        specs = [[commit_id, 'CHANGELOG'], [commit_id, 'CONTRIBUTING.md']]
        expect(repository).to receive(:blobs_at)
          .with(specs, blob_size_limit: blob_size_limit)
          .once
          .and_call_original

        expect(other_repository).not_to receive(:blobs_at)

        changelog = described_class.lazy(commit_id, 'CHANGELOG', repository: repository)
        contributing = described_class.lazy(commit_id, 'CONTRIBUTING.md', repository: same_repository)

        described_class.lazy(commit_id, 'CHANGELOG', repository: other_repository)

        # Access property so the values are loaded
        changelog.id
        contributing.id
      end

      it 'does not include blobs from previous requests in later requests' do
        changelog = described_class.lazy(commit_id, 'CHANGELOG', repository: repository)
        contributing = described_class.lazy(commit_id, 'CONTRIBUTING.md', repository: same_repository)

        # Access property so the values are loaded
        changelog.id
        contributing.id

        readme = described_class.lazy(commit_id, 'README.md', repository: repository)

        expect(repository).to receive(:blobs_at)
          .with([[commit_id, 'README.md']], blob_size_limit: blob_size_limit)
          .once
          .and_call_original

        readme.id
      end
    end

    context 'with project' do
      let_it_be(:project) { create(:project, :repository) }
      let_it_be(:other_project) { create(:project, :repository) }

      let(:repository) { project.repository }
      let(:same_repository) { Project.find(project.id).repository }
      let(:other_repository) { other_project.repository }

      it_behaves_like '.lazy checks'
    end

    context 'with personal snippet' do
      let_it_be(:snippet) { create(:personal_snippet) }
      let_it_be(:other_snippet) { create(:personal_snippet) }

      let(:repository) { snippet.repository }
      let(:same_repository) { PersonalSnippet.find(snippet.id).repository }
      let(:other_repository) { other_snippet.repository }

      it_behaves_like '.lazy checks'
    end

    context 'with project snippet' do
      let_it_be(:snippet) { create(:project_snippet) }
      let_it_be(:other_snippet) { create(:project_snippet) }

      let(:repository) { snippet.repository }
      let(:same_repository) { ProjectSnippet.find(snippet.id).repository }
      let(:other_repository) { other_snippet.repository }

      it_behaves_like '.lazy checks'
    end
  end

  describe '#data' do
    shared_examples '#data checks' do
      context 'using a binary blob' do
        it 'returns the data as-is' do
          data = "\n\xFF\xB9\xC3"
          blob = fake_blob(binary: true, data: data)

          expect(blob.data).to eq(data)
        end
      end

      context 'using a text blob' do
        it 'converts the data to UTF-8' do
          blob = fake_blob(binary: false, data: "\n\xFF\xB9\xC3")

          expect(blob.data).to eq("\n���")
        end
      end
    end

    context 'with project' do
      let(:repository) { project.repository }

      it_behaves_like '#data checks'
    end

    context 'with personal snippet' do
      let(:repository) { personal_snippet.repository }

      it_behaves_like '#data checks'
    end

    context 'with project snippet' do
      let(:repository) { project_snippet.repository }

      it_behaves_like '#data checks'
    end
  end

  describe '#external_storage_error?' do
    subject { blob.external_storage_error? }

    context 'if the blob is stored in LFS' do
      let(:blob) { fake_blob(path: 'file.pdf', lfs: true, repository: repository) }

      context 'when LFS is enabled' do
        let(:lfs_enabled) { true }

        it { is_expected.to be_falsy }
      end

      context 'when LFS is not enabled' do
        let(:lfs_enabled) { false }

        it { is_expected.to be_truthy }
      end
    end

    context 'if the blob is not stored in LFS' do
      let(:blob) { fake_blob(path: 'file.md', repository: repository) }

      it { is_expected.to be_falsy }
    end
  end

  describe '#stored_externally?' do
    subject { blob.stored_externally? }

    context 'if the blob is stored in LFS' do
      let(:blob) { fake_blob(path: 'file.pdf', lfs: true, repository: repository) }

      context 'when LFS is enabled' do
        let(:lfs_enabled) { true }

        it { is_expected.to be_truthy }
      end

      context 'when LFS is not enabled' do
        let(:lfs_enabled) { false }

        it { is_expected.to be_falsy }
      end
    end

    context 'if the blob is not stored in LFS' do
      let(:blob) { fake_blob(path: 'file.md', repository: repository) }

      it { is_expected.to be_falsy }
    end
  end

  describe '#binary?' do
    context 'an lfs object' do
      where(:filename, :is_binary) do
        'file.pdf' | true
        'file.md'  | false
        'file.txt' | false
        'file.ics' | false
        'file.rb'  | false
        'file.exe' | true
        'file.ini' | false
        'file.wtf' | true
      end

      with_them do
        let(:blob) { fake_blob(path: filename, lfs: true, repository: repository) }

        it { expect(blob.binary?).to eq(is_binary) }
      end
    end

    context 'a non-lfs object' do
      let(:blob) { fake_blob(path: 'anything', repository: repository) }

      it 'delegates to binary_in_repo?' do
        expect(blob).to receive(:binary_in_repo?) { :result }

        expect(blob.binary?).to eq(:result)
      end
    end
  end

  describe '#extension' do
    it 'returns the extension' do
      blob = fake_blob(path: 'file.md', repository: repository)

      expect(blob.extension).to eq('md')
    end
  end

  describe '#file_type' do
    it 'returns the file type' do
      blob = fake_blob(path: 'README.md', repository: repository)

      expect(blob.file_type).to eq(:readme)
    end
  end

  describe '#simple_viewer' do
    context 'when the blob is empty' do
      it 'returns an empty viewer' do
        blob = fake_blob(data: '', size: 0, repository: repository)

        expect(blob.simple_viewer).to be_a(BlobViewer::Empty)
      end
    end

    context 'when the file represented by the blob is binary' do
      it 'returns a download viewer' do
        blob = fake_blob(binary: true, repository: repository)

        expect(blob.simple_viewer).to be_a(BlobViewer::Download)
      end
    end

    context 'when the file represented by the blob is text-based' do
      it 'returns a text viewer' do
        blob = fake_blob(repository: repository)

        expect(blob.simple_viewer).to be_a(BlobViewer::Text)
      end
    end
  end

  describe '#rich_viewer' do
    context 'when the blob has an external storage error' do
      let(:lfs_enabled) { false }

      it 'returns nil' do
        blob = fake_blob(path: 'file.pdf', lfs: true, repository: repository)

        expect(blob.rich_viewer).to be_nil
      end
    end

    context 'when the blob is empty' do
      it 'returns nil' do
        blob = fake_blob(data: '', repository: repository)

        expect(blob.rich_viewer).to be_nil
      end
    end

    context 'when the blob is stored externally' do
      it 'returns a matching viewer' do
        blob = fake_blob(path: 'file.pdf', lfs: true, repository: repository)

        expect(blob.rich_viewer).to be_a(BlobViewer::PDF)
      end
    end

    context 'when the blob is binary' do
      it 'returns a matching binary viewer' do
        blob = fake_blob(path: 'file.pdf', binary: true, repository: repository)

        expect(blob.rich_viewer).to be_a(BlobViewer::PDF)
      end
    end

    context 'when the blob is text-based' do
      it 'returns a matching text-based viewer' do
        blob = fake_blob(path: 'file.md', repository: repository)

        expect(blob.rich_viewer).to be_a(BlobViewer::Markup)
      end
    end

    context 'when the blob is video' do
      it 'returns a video viewer' do
        blob = fake_blob(path: 'file.mp4', binary: true, repository: repository)

        expect(blob.rich_viewer).to be_a(BlobViewer::Video)
      end
    end

    context 'when the blob is audio' do
      it 'returns an audio viewer' do
        blob = fake_blob(path: 'file.wav', binary: true, repository: repository)

        expect(blob.rich_viewer).to be_a(BlobViewer::Audio)
      end
    end
  end

  describe '#auxiliary_viewer' do
    context 'when the blob has an external storage error' do
      let(:lfs_enabled) { false }

      it 'returns nil' do
        blob = fake_blob(path: 'LICENSE', lfs: true, repository: repository)

        expect(blob.auxiliary_viewer).to be_nil
      end
    end

    context 'when the blob is empty' do
      it 'returns nil' do
        blob = fake_blob(data: '')

        expect(blob.auxiliary_viewer).to be_nil
      end
    end

    context 'when the blob is stored externally' do
      it 'returns a matching viewer' do
        blob = fake_blob(path: 'LICENSE', lfs: true, repository: repository)

        expect(blob.auxiliary_viewer).to be_a(BlobViewer::License)
      end
    end

    context 'when the blob is binary' do
      it 'returns nil' do
        blob = fake_blob(path: 'LICENSE', binary: true, repository: repository)

        expect(blob.auxiliary_viewer).to be_nil
      end
    end

    context 'when the blob is text-based' do
      it 'returns a matching text-based viewer' do
        blob = fake_blob(path: 'LICENSE', repository: repository)

        expect(blob.auxiliary_viewer).to be_a(BlobViewer::License)
      end
    end
  end

  describe '#rendered_as_text?' do
    subject { blob.rendered_as_text?(ignore_errors: ignore_errors) }

    context 'when ignoring errors' do
      let(:ignore_errors) { true }

      context 'when the simple viewer is text-based' do
        let(:blob) { fake_blob(path: 'file.md', size: 100.megabytes, repository: repository) }

        it { is_expected.to be_truthy }
      end

      context 'when the simple viewer is binary' do
        let(:blob) { fake_blob(path: 'file.pdf', binary: true, size: 100.megabytes, repository: repository) }

        it { is_expected.to be_falsy }
      end
    end

    context 'when not ignoring errors' do
      let(:ignore_errors) { false }

      context 'when the viewer has render errors' do
        let(:blob) { fake_blob(path: 'file.md', size: 100.megabytes, repository: repository) }

        it { is_expected.to be_falsy }
      end

      context "when the viewer doesn't have render errors" do
        let(:blob) { fake_blob(path: 'file.md', repository: repository) }

        it { is_expected.to be_truthy }
      end
    end
  end
end
