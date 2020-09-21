# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlobHelper do
  include TreeHelper

  describe '#highlight' do
    it 'wraps highlighted content' do
      expect(helper.highlight('test.rb', '52')).to eq(%q[<pre class="code highlight"><code><span id="LC1" class="line" lang="ruby"><span class="mi">52</span></span></code></pre>])
    end

    it 'handles plain version' do
      expect(helper.highlight('test.rb', '52', plain: true)).to eq(%q[<pre class="code highlight"><code><span id="LC1" class="line" lang="">52</span></code></pre>])
    end
  end

  describe "#sanitize_svg_data" do
    let(:input_svg_path) { File.join(Rails.root, 'spec', 'fixtures', 'unsanitized.svg') }
    let(:data) { File.read(input_svg_path) }
    let(:expected_svg_path) { File.join(Rails.root, 'spec', 'fixtures', 'sanitized.svg') }
    let(:expected) { File.read(expected_svg_path) }

    it 'retains essential elements' do
      expect(sanitize_svg_data(data)).to eq(expected)
    end
  end

  describe "#edit_blob_link" do
    let(:namespace) { create(:namespace, name: 'gitlab') }
    let(:project) { create(:project, :repository, namespace: namespace) }

    subject(:link) { helper.edit_blob_button(project, 'master', 'README.md') }

    before do
      allow(helper).to receive(:current_user).and_return(nil)
      allow(helper).to receive(:can?).and_return(true)
      allow(helper).to receive(:can_collaborate_with_project?).and_return(true)
    end

    it 'verifies blob is text' do
      expect(helper).not_to receive(:blob_text_viewable?)

      button = helper.edit_blob_button(project, 'refs/heads/master', 'README.md')

      expect(button).to start_with('<button')
    end

    it 'uses the passed blob instead retrieve from repository' do
      blob = project.repository.blob_at('refs/heads/master', 'README.md')

      expect(project.repository).not_to receive(:blob_at)

      helper.edit_blob_button(project, 'refs/heads/master', 'README.md', blob: blob)
    end

    it 'returns a link with the proper route' do
      expect(Capybara.string(link).find_link('Edit')[:href]).to eq("/#{project.full_path}/-/edit/master/README.md")
    end

    it 'returns a link with the passed link_opts on the expected route' do
      link_with_mr = helper.edit_blob_button(project, 'master', 'README.md', link_opts: { mr_id: 10 })

      expect(Capybara.string(link_with_mr).find_link('Edit')[:href]).to eq("/#{project.full_path}/-/edit/master/README.md?mr_id=10")
    end

    context 'when edit is the primary button' do
      before do
        stub_feature_flags(web_ide_primary_edit: false)
      end

      it 'is rendered as primary' do
        expect(link).not_to match(/btn-inverted/)
      end

      it 'passes on primary tracking attributes' do
        parsed_link = Capybara.string(link).find_link('Edit')

        expect(parsed_link[:'data-track-event']).to eq("click_edit")
        expect(parsed_link[:'data-track-label']).to eq("Edit")
        expect(parsed_link[:'data-track-property']).to eq(nil)
      end
    end

    context 'when Web IDE is the primary button' do
      before do
        stub_feature_flags(web_ide_primary_edit: true)
      end

      it 'is rendered as inverted' do
        expect(link).to match(/btn-inverted/)
      end

      it 'passes on secondary tracking attributes' do
        parsed_link = Capybara.string(link).find_link('Edit')

        expect(parsed_link[:'data-track-event']).to eq("click_edit")
        expect(parsed_link[:'data-track-label']).to eq("Edit")
        expect(parsed_link[:'data-track-property']).to eq("secondary")
      end
    end
  end

  context 'viewer related' do
    include FakeBlobHelpers

    let(:project) { build(:project, lfs_enabled: true) }

    before do
      allow(Gitlab.config.lfs).to receive(:enabled).and_return(true)
    end

    let(:viewer_class) do
      Class.new(BlobViewer::Base) do
        include BlobViewer::ServerSide

        self.collapse_limit = 1.megabyte
        self.size_limit = 5.megabytes
        self.type = :rich
      end
    end

    let(:viewer) { viewer_class.new(blob) }
    let(:blob) { fake_blob }

    describe '#blob_render_error_reason' do
      context 'for error :too_large' do
        context 'when the blob size is larger than the absolute size limit' do
          let(:blob) { fake_blob(size: 10.megabytes) }

          it 'returns an error message' do
            expect(helper.blob_render_error_reason(viewer)).to eq('it is larger than 5 MB')
          end
        end

        context 'when the blob size is larger than the size limit' do
          let(:blob) { fake_blob(size: 2.megabytes) }

          it 'returns an error message' do
            expect(helper.blob_render_error_reason(viewer)).to eq('it is larger than 1 MB')
          end
        end
      end

      context 'for error :server_side_but_stored_externally' do
        let(:blob) { fake_blob(lfs: true) }

        it 'returns an error message' do
          expect(helper.blob_render_error_reason(viewer)).to eq('it is stored in LFS')
        end
      end
    end

    describe '#blob_render_error_options' do
      before do
        assign(:project, project)
        assign(:blob, blob)
        assign(:id, File.join('master', blob.path))

        controller.params[:controller] = 'projects/blob'
        controller.params[:action] = 'show'
        controller.params[:namespace_id] = project.namespace.to_param
        controller.params[:project_id] = project.to_param
        controller.params[:id] = File.join('master', blob.path)
      end

      context 'for error :collapsed' do
        let(:blob) { fake_blob(size: 2.megabytes) }

        it 'includes a "load it anyway" link' do
          expect(helper.blob_render_error_options(viewer)).to include(/load it anyway/)
        end
      end

      context 'for error :too_large' do
        let(:blob) { fake_blob(size: 10.megabytes) }

        it 'does not include a "load it anyway" link' do
          expect(helper.blob_render_error_options(viewer)).not_to include(/load it anyway/)
        end

        context 'when the viewer is rich' do
          context 'the blob is rendered as text' do
            let(:blob) { fake_blob(path: 'file.md', size: 2.megabytes) }

            it 'includes a "view the source" link' do
              expect(helper.blob_render_error_options(viewer)).to include(/view the source/)
            end
          end

          context 'the blob is not rendered as text' do
            let(:blob) { fake_blob(path: 'file.pdf', binary: true, size: 2.megabytes) }

            it 'does not include a "view the source" link' do
              expect(helper.blob_render_error_options(viewer)).not_to include(/view the source/)
            end
          end
        end

        context 'when the viewer is not rich' do
          before do
            viewer_class.type = :simple
          end

          let(:blob) { fake_blob(path: 'file.md', size: 2.megabytes) }

          it 'does not include a "view the source" link' do
            expect(helper.blob_render_error_options(viewer)).not_to include(/view the source/)
          end
        end

        it 'includes a "download it" link' do
          expect(helper.blob_render_error_options(viewer)).to include(/download it/)
        end
      end

      context 'for error :server_side_but_stored_externally' do
        let(:blob) { fake_blob(path: 'file.md', lfs: true) }

        it 'does not include a "load it anyway" link' do
          expect(helper.blob_render_error_options(viewer)).not_to include(/load it anyway/)
        end

        it 'does not include a "view the source" link' do
          expect(helper.blob_render_error_options(viewer)).not_to include(/view the source/)
        end

        it 'includes a "download it" link' do
          expect(helper.blob_render_error_options(viewer)).to include(/download it/)
        end
      end
    end

    describe '#show_suggest_pipeline_creation_celebration?' do
      let(:current_user) { create(:user) }

      before do
        assign(:project, project)
        assign(:blob, blob)
        assign(:commit, double('Commit', sha: 'whatever'))
        helper.request.cookies["suggest_gitlab_ci_yml_commit_#{project.id}"] = 'true'
        allow(helper).to receive(:current_user).and_return(current_user)
      end

      context 'when file is a pipeline config file' do
        let(:data) { File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci.yml')) }
        let(:blob) { fake_blob(path: Gitlab::FileDetector::PATTERNS[:gitlab_ci], data: data) }

        context 'experiment enabled' do
          before do
            allow(helper).to receive(:experiment_enabled?).and_return(true)
          end

          it 'is true' do
            expect(helper.show_suggest_pipeline_creation_celebration?).to be_truthy
          end

          context 'file is invalid format' do
            let(:data) { 'foo' }

            it 'is false' do
              expect(helper.show_suggest_pipeline_creation_celebration?).to be_falsey
            end
          end

          context 'does not use the default ci config' do
            before do
              project.ci_config_path = 'something_bad'
            end

            it 'is false' do
              expect(helper.show_suggest_pipeline_creation_celebration?).to be_falsey
            end
          end

          context 'does not have the needed cookie' do
            before do
              helper.request.cookies.delete "suggest_gitlab_ci_yml_commit_#{project.id}"
            end

            it 'is false' do
              expect(helper.show_suggest_pipeline_creation_celebration?).to be_falsey
            end
          end

          context 'blob does not have auxiliary view' do
            before do
              allow(blob).to receive(:auxiliary_viewer).and_return(nil)
            end

            it 'is false' do
              expect(helper.show_suggest_pipeline_creation_celebration?).to be_falsey
            end
          end
        end

        context 'experiment disabled' do
          before do
            allow(helper).to receive(:experiment_enabled?).and_return(false)
          end

          it 'is false' do
            expect(helper.show_suggest_pipeline_creation_celebration?).to be_falsey
          end
        end
      end

      context 'when file is not a pipeline config file' do
        let(:blob) { fake_blob(path: 'LICENSE') }

        context 'experiment enabled' do
          before do
            allow(helper).to receive(:experiment_enabled?).and_return(true)
          end

          it 'is false' do
            expect(helper.show_suggest_pipeline_creation_celebration?).to be_falsey
          end
        end
      end
    end
  end

  describe 'suggest_pipeline_commit_cookie_name' do
    let(:project) { create(:project) }

    it 'uses project id to make up the cookie name' do
      assign(:project, project)

      expect(helper.suggest_pipeline_commit_cookie_name).to eq "suggest_gitlab_ci_yml_commit_#{project.id}"
    end
  end

  describe `#ide_edit_button` do
    let_it_be(:namespace) { create(:namespace, name: 'gitlab') }
    let_it_be(:project) { create(:project, :repository, namespace: namespace) }
    let_it_be(:current_user) { create(:user) }
    let(:can_push_code) { true }
    let(:blob) { project.repository.blob_at('refs/heads/master', 'README.md') }

    subject(:link) { helper.ide_edit_button(project, 'master', 'README.md', blob: blob) }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
      allow(helper).to receive(:can?).with(current_user, :push_code, project).and_return(can_push_code)
      allow(helper).to receive(:can_collaborate_with_project?).and_return(true)
    end

    it 'returns a link with a Web IDE route' do
      expect(Capybara.string(link).find_link('Web IDE')[:href]).to eq("/-/ide/project/#{project.full_path}/edit/master/-/README.md")
    end

    context 'when edit is the primary button' do
      before do
        stub_feature_flags(web_ide_primary_edit: false)
      end

      it 'is rendered as inverted' do
        expect(link).to match(/btn-inverted/)
      end

      it 'passes on secondary tracking attributes' do
        parsed_link = Capybara.string(link).find_link('Web IDE')

        expect(parsed_link[:'data-track-event']).to eq("click_edit_ide")
        expect(parsed_link[:'data-track-label']).to eq("Web IDE")
        expect(parsed_link[:'data-track-property']).to eq("secondary")
      end
    end

    context 'when Web IDE is the primary button' do
      before do
        stub_feature_flags(web_ide_primary_edit: true)
      end

      it 'is rendered as primary' do
        expect(link).not_to match(/btn-inverted/)
      end

      it 'passes on primary tracking attributes' do
        parsed_link = Capybara.string(link).find_link('Web IDE')

        expect(parsed_link[:'data-track-event']).to eq("click_edit_ide")
        expect(parsed_link[:'data-track-label']).to eq("Web IDE")
        expect(parsed_link[:'data-track-property']).to eq(nil)
      end
    end
  end

  describe '#ide_edit_path' do
    let(:project) { create(:project) }
    let(:current_user) { create(:user) }
    let(:can_push_code) { true }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
      allow(helper).to receive(:can?).and_return(can_push_code)
    end

    around do |example|
      old_script_name = Rails.application.routes.default_url_options[:script_name]
      begin
        example.run
      ensure
        Rails.application.routes.default_url_options[:script_name] = old_script_name
      end
    end

    it 'returns full IDE path' do
      Rails.application.routes.default_url_options[:script_name] = nil

      expect(helper.ide_edit_path(project, "master", "")).to eq("/-/ide/project/#{project.namespace.path}/#{project.path}/edit/master")
    end

    it 'returns full IDE path with second -' do
      Rails.application.routes.default_url_options[:script_name] = nil

      expect(helper.ide_edit_path(project, "testing/slashes", "readme.md")).to eq("/-/ide/project/#{project.namespace.path}/#{project.path}/edit/testing/slashes/-/readme.md")
    end

    it 'returns IDE path without relative_url_root' do
      Rails.application.routes.default_url_options[:script_name] = "/gitlab"

      expect(helper.ide_edit_path(project, "master", "")).to eq("/gitlab/-/ide/project/#{project.namespace.path}/#{project.path}/edit/master")
    end

    it 'escapes special characters' do
      Rails.application.routes.default_url_options[:script_name] = nil

      expect(helper.ide_edit_path(project, "testing/#hashes", "readme.md#test")).to eq("/-/ide/project/#{project.full_path}/edit/testing/%23hashes/-/readme.md%23test")
      expect(helper.ide_edit_path(project, "testing/#hashes", "src#/readme.md#test")).to eq("/-/ide/project/#{project.full_path}/edit/testing/%23hashes/-/src%23/readme.md%23test")
    end

    it 'does not escape "/" character' do
      Rails.application.routes.default_url_options[:script_name] = nil

      expect(helper.ide_edit_path(project, "testing/slashes", "readme.md/")).to eq("/-/ide/project/#{project.namespace.path}/#{project.path}/edit/testing/slashes/-/readme.md/")
    end

    context 'when user is not logged in' do
      let(:current_user) { nil }

      it 'returns IDE path inside the project' do
        expect(helper.ide_edit_path(project, "master", "")).to eq("/-/ide/project/#{project.namespace.path}/#{project.path}/edit/master")
      end
    end

    context 'when user cannot push to the project' do
      let(:can_push_code) { false }

      it "returns IDE path with the user's fork" do
        expect(helper.ide_edit_path(project, "master", "")).to eq("/-/ide/project/#{current_user.namespace.full_path}/#{project.path}/edit/master")
      end
    end
  end

  describe '#ide_fork_and_edit_path' do
    let(:project) { create(:project) }
    let(:current_user) { create(:user) }
    let(:can_push_code) { true }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
      allow(helper).to receive(:can?).and_return(can_push_code)
    end

    it 'returns path to fork the repo with a redirect param to the full IDE path' do
      uri = URI(helper.ide_fork_and_edit_path(project, "master", ""))
      params = CGI.unescape(uri.query)

      expect(uri.path).to eq("/#{project.namespace.path}/#{project.path}/-/forks")
      expect(params).to include("continue[to]=/-/ide/project/#{project.namespace.path}/#{project.path}/edit/master")
      expect(params).to include("namespace_key=#{current_user.namespace.id}")
    end

    context 'when user is not logged in' do
      let(:current_user) { nil }

      it 'returns nil' do
        expect(helper.ide_fork_and_edit_path(project, "master", "")).to be_nil
      end
    end
  end
end
