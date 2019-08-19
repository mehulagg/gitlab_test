# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::PackageTag, type: :model do
  let!(:project) { create(:project) }
  let!(:package) { create(:npm_package, version: '1.0.2', project: project) }

  describe 'relationships' do
    it { is_expected.to belong_to(:package) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:package) }
  end

end
