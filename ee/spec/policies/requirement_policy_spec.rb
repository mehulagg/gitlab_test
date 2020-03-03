# frozen_string_literal: true

require 'spec_helper'

describe RequirementPolicy do
  let_it_be(:owner) { create(:user) }
  let_it_be(:admin) { create(:admin) }
  let_it_be(:reporter) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:project) { create(:project, :public, namespace: owner.namespace) }
  let_it_be(:resource, reload: true) { create(:requirement, project: project) }

  before do
    project.add_reporter(reporter)
    project.add_guest(guest)
  end

  it_behaves_like 'resource with requirement permissions'
end
