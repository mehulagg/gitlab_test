# frozen_string_literal: true

require 'spec_helper'

describe Banzai::Filter::FeatureFlagReferenceFilter do
  include FilterSpecHelper

  let_it_be(:project) { create(:project, :public) }

  let(:feature_flag) { create(:operations_feature_flag, :new_version_flag, project: project) }

  it 'links with adjacent text' do
    doc = reference_filter("See #{feature_flag.to_reference}")
    link = doc.css('a').first.attr('href')

    expect(link).to eq(urls.project_feature_flag_url(project, feature_flag))
  end

  it 'returns only the path with an :only_path context' do
    doc = reference_filter("Feature Flag #{feature_flag.to_reference}", only_path: true)
    link = doc.css('a').first.attr('href')

    expect(link).not_to match %r(https?://)
    expect(link).to eq(urls.project_feature_flag_url(project, feature_flag, only_path: true))
  end
end
