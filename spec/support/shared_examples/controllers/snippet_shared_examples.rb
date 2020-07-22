# frozen_string_literal: true

RSpec.shared_examples 'show json request' do
  it 'returns all snippet blobs' do
    subject

    expect(response).to have_gitlab_http_status(:ok)
    expect(json_response.size).to eq snippet.blobs.count
    expect(json_response.map { |s| s.key?('html') }).to be_all(true)
  end
end
