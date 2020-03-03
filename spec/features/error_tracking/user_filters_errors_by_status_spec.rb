# frozen_string_literal: true

require 'spec_helper'

describe 'When a user filters Sentry errors by status', :js, :use_clean_rails_memory_store_caching, :sidekiq_inline do
  include_context 'sentry error tracking context feature'

  let_it_be(:issues_response_body) { fixture_file('sentry/issues_sample_response.json') }
  let_it_be(:filtered_errors_by_status_response) { fixture_file('sentry/filtered_errors_by_status_response.json') }
  let(:issues_api_url) { "#{sentry_api_urls.issues_url}?limit=20&query=is:unresolved" }
  let(:issues_api_url_filter) { "#{sentry_api_urls.issues_url}?limit=20&query=is:ignored" }

  before do
    stub_request(:get, issues_api_url).with(
      headers: { 'Authorization' => 'Bearer access_token_123' }
    ).to_return(status: 200, body: issues_response_body, headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, issues_api_url_filter).with(
      headers: { 'Authorization' => 'Bearer access_token_123', 'Content-Type' => 'application/json' }
    ).to_return(status: 200, body: filtered_errors_by_status_response, headers: { 'Content-Type' => 'application/json' })
  end

  it 'displays the results' do
    sign_in(project.owner)
    visit project_error_tracking_index_path(project)
    page.within(find('.gl-table')) do
      results = page.all('.table-row')
      expect(results.count).to be(2)
    end

    find('.status-dropdown .dropdown-toggle').click
    find('.dropdown-item', text: 'Ignored').click

    page.within(find('.gl-table')) do
      results = page.all('.table-row')
      expect(results.count).to be(1)
      expect(results.first).to have_content('Service unknown')
    end
  end
end
