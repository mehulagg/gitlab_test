# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'EE IDE user commits changes', :js do
  include WebIdeSpecHelpers

  let(:project) { create(:project, :custom_repo, files: { 'docs/CODEOWNERS' => "[Backend]\n*.rb @ruby-owner" }) }
  let(:ruby_owner) { create(:user, username: 'ruby-owner') }
  let(:user) { project.owner }

  before do
    stub_licensed_features(code_owners: true, code_owner_approval_required: true)

    project.add_developer(ruby_owner)

    create(:protected_branch,
      name: 'master',
      code_owner_approval_required: true,
      project: project)

    sign_in(user)

    ide_visit(project)
  end

  it 'shows error message' do
    ide_create_new_file('test.rb', content: '# A ruby file')

    ide_commit

    expect(page).to have_content('CODEOWNERS rule violation')
  end
end
