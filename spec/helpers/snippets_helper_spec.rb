# frozen_string_literal: true

require 'spec_helper'

describe SnippetsHelper do
  include Gitlab::Routing
  include IconsHelper

  let_it_be(:user) { create(:user) }
  let_it_be(:personal_snippet) { create(:personal_snippet, :public, :repository, author: user) }
  let_it_be(:project_snippet) { create(:project_snippet, :public, :repository, author: user) }

  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#embedded_raw_snippet_button' do
    subject { helper.embedded_raw_snippet_button(snippet.blob) }

    context 'personal snippets' do
      let(:snippet) { personal_snippet}

      it 'returns blob raw button of embedded snippets' do
        expect(subject).to eq(download_link("http://test.host/snippets/#{snippet.id}/blobs/filename-1.rb/raw"))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns raw button of the whole embedded snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(download_link("http://test.host/snippets/#{snippet.id}/raw"))
        end
      end
    end

    context 'project snippets' do
      let(:snippet) { project_snippet}

      it 'returns view raw button of embedded snippets' do
        expect(subject).to eq(download_link("http://test.host/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/blobs/filename-2.rb/raw"))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns raw button of the whole embedded snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(download_link("http://test.host/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/raw"))
        end
      end
    end

    def download_link(url)
      "<a class=\"btn\" target=\"_blank\" title=\"Open raw\" rel=\"noopener noreferrer\" href=\"#{url}\">#{external_snippet_icon('doc-code')}</a>"
    end
  end

  describe '#embedded_snippet_download_button' do
    subject { helper.embedded_snippet_download_button(snippet.blob) }

    context 'personal snippets' do
      let(:snippet) { personal_snippet}

      it 'returns download button of embedded snippets' do
        expect(subject).to eq(download_link("http://test.host/snippets/#{snippet.id}/blobs/filename-1.rb/raw"))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns download button of the whole embedded snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(download_link("http://test.host/snippets/#{snippet.id}/raw"))
        end
      end
    end

    context 'project snippets' do
      let(:snippet) { project_snippet}

      it 'returns download button of embedded snippets for project snippets' do
        expect(subject).to eq(download_link("http://test.host/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/blobs/filename-2.rb/raw"))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns download button of the whole embedded snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(download_link("http://test.host/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/raw"))
        end
      end
    end

    def download_link(url)
      "<a class=\"btn\" target=\"_blank\" title=\"Download\" rel=\"noopener noreferrer\" href=\"#{url}?inline=false\">#{external_snippet_icon('download')}</a>"
    end
  end

  describe '#download_raw_snippet_button' do
    subject { helper.download_raw_snippet_button(snippet.blob) }

    context 'personal snippets' do
      let(:snippet) { personal_snippet}

      it 'returns download button for blob' do
        expect(subject).to eq(button_link("/snippets/#{snippet.id}/blobs/filename-1.rb/raw?inline=false", icon('download')))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns download button for snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(button_link("/snippets/#{snippet.id}/raw?inline=false", icon('download')))
        end
      end
    end

    context 'project snippets' do
      let(:snippet) { project_snippet}

      it 'returns download button for blob' do
        expect(subject).to eq(button_link("/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/blobs/filename-2.rb/raw?inline=false", icon('download')))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns download button for snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(button_link("/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/raw?inline=false", icon('download')))
        end
      end
    end

    def button_link(url, icon)
      "<a class=\"btn btn-sm has-tooltip\" target=\"_blank\" rel=\"noopener noreferrer\" aria-label=\"Download\" title=\"Download\" data-container=\"body\" href=\"#{url}\">#{icon}</a>"
    end
  end

  describe '#open_raw_snippet_button' do
    subject { helper.open_raw_snippet_button(snippet.blob) }

    context 'personal snippets' do
      let(:snippet) { personal_snippet}

      it 'returns download button for blob' do
        expect(subject).to eq(button_link("/snippets/#{snippet.id}/blobs/filename-1.rb/raw", sprite_icon('doc-code')))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns download button for snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(button_link("/snippets/#{snippet.id}/raw", sprite_icon('doc-code')))
        end
      end
    end

    context 'project snippets' do
      let(:snippet) { project_snippet}

      it 'returns download button for blob' do
        expect(subject).to eq(button_link("/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/blobs/filename-2.rb/raw", sprite_icon('doc-code')))
      end

      context 'when feature flag :version_snippets is disabled' do
        it 'returns download button for snippet' do
          stub_feature_flags(version_snippets: false)

          expect(subject).to eq(button_link("/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}/raw", sprite_icon('doc-code')))
        end
      end
    end

    def button_link(url, icon)
      "<a class=\"btn btn-sm has-tooltip\" target=\"_blank\" rel=\"noopener noreferrer\" aria-label=\"Open raw\" title=\"Open raw\" data-container=\"body\" href=\"#{url}\">#{icon}</a>"
    end
  end

  describe '#snippet_embed_tag' do
    subject { helper.snippet_embed_tag(snippet) }

    context 'personal snippets' do
      let(:snippet) { personal_snippet }

      context 'public' do
        it 'returns a script tag with the snippet full url' do
          expect(subject).to eq(script_embed("http://test.host/snippets/#{snippet.id}"))
        end
      end
    end

    context 'project snippets' do
      let(:snippet) { project_snippet }

      it 'returns a script tag with the snippet full url' do
        expect(subject).to eq(script_embed("http://test.host/#{snippet.project.path_with_namespace}/snippets/#{snippet.id}"))
      end
    end

    def script_embed(url)
      "<script src=\"#{url}.js\"></script>"
    end
  end

  describe '#snippet_badge' do
    let(:snippet) { build(:personal_snippet, visibility) }

    subject { helper.snippet_badge(snippet) }

    context 'when snippet is private' do
      let(:visibility) { :private }

      it 'returns the snippet badge' do
        expect(subject).to eq "<span class=\"badge badge-gray\"><i class=\"fa fa-lock\"></i> private</span>"
      end
    end

    context 'when snippet is public' do
      let(:visibility) { :public }

      it 'does not return anything' do
        expect(subject).to be_nil
      end
    end

    context 'when snippet is internal' do
      let(:visibility) { :internal }

      it 'does not return anything' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#snippet_embed_input' do
    subject { helper.snippet_embed_input(snippet) }

    context 'with PersonalSnippet' do
      let(:snippet) { personal_snippet }

      it 'returns the input component' do
        expect(subject).to eq embed_input(snippet_url(snippet))
      end
    end

    context 'with ProjectSnippet' do
      let(:snippet) { project_snippet }

      it 'returns the input component' do
        expect(subject).to eq embed_input(project_snippet_url(snippet.project, snippet))
      end
    end

    def embed_input(url)
      "<input type=\"text\" readonly=\"readonly\" class=\"js-snippet-url-area snippet-embed-input form-control\" data-url=\"#{url}\" value=\"<script src=&quot;#{url}.js&quot;></script>\" autocomplete=\"off\"></input>"
    end
  end
end
