# frozen_string_literal: true

RSpec.shared_examples 'diff discussions API' do |parent_type, noteable_type, id_name|
  describe "GET /#{parent_type}/:id/#{noteable_type}/:noteable_id/discussions" do
    it "includes diff discussions" do
      get api("/#{parent_type}/#{parent.id}/#{noteable_type}/#{noteable[id_name]}/discussions", user)

      discussion = json_response.find { |record| record['id'] == diff_note.discussion_id }

      expect(response).to have_gitlab_http_status(:ok)
      expect(discussion).not_to be_nil
      expect(discussion['individual_note']).to eq(false)
      expect(discussion['notes'].first['body']).to eq(diff_note.note)
    end
  end

  describe "GET /#{parent_type}/:id/#{noteable_type}/:noteable_id/discussions/:discussion_id" do
    before do
      get api("/#{parent_type}/#{parent.id}/#{noteable_type}/#{noteable[id_name]}/discussions/#{diff_note.discussion_id}", user)
    end

    it "is successful" do
      expect(response).to have_gitlab_http_status(:ok)
    end

    it "returns a discussion by id" do
      expect(json_response['id']).to eq(diff_note.discussion_id)
    end

    it "returns the note body" do
      expect(json_response['notes'].first['body']).to eq(diff_note.note)
    end

    it "returns the note position" do
      expect(json_response['notes'].first['position']).to eq(diff_note.position.to_h.stringify_keys)
    end

    it "returns the note position additional_lines attribute" do
      expect(json_response['notes'].first['position']['additional_lines']).to eq(0)
    end
  end

  describe "POST /#{parent_type}/:id/#{noteable_type}/:noteable_id/discussions" do
    it "creates a new diff note" do
      position = diff_note.position.to_h.merge({ additional_lines: -5 })

      post api("/#{parent_type}/#{parent.id}/#{noteable_type}/#{noteable[id_name]}/discussions", user),
        params: { body: 'hi!', position: position }

      expect(response).to have_gitlab_http_status(:created)
      expect(json_response['notes'].first['body']).to eq('hi!')
      expect(json_response['notes'].first['type']).to eq('DiffNote')
      expect(json_response['notes'].first['position']).to eq(position.stringify_keys)
    end

    context "when position is invalid" do
      it "returns a 400 bad request error when position is not plausible" do
        position = diff_note.position.to_h.merge(new_line: '100000')

        post api("/#{parent_type}/#{parent.id}/#{noteable_type}/#{noteable[id_name]}/discussions", user),
          params: { body: 'hi!', position: position }

        expect(response).to have_gitlab_http_status(:bad_request)
      end

      it "returns a 400 bad request error when the position is not valid for this discussion" do
        position = diff_note.position.to_h.merge(new_line: '588440f66559714280628a4f9799f0c4eb880a4a')

        post api("/#{parent_type}/#{parent.id}/#{noteable_type}/#{noteable[id_name]}/discussions", user),
          params: { body: 'hi!', position: position }

        expect(response).to have_gitlab_http_status(:bad_request)
      end
    end
  end

  describe "POST /#{parent_type}/:id/#{noteable_type}/:noteable_id/discussions/:discussion_id/notes" do
    it 'adds a new note to the diff discussion' do
      post api("/#{parent_type}/#{parent.id}/#{noteable_type}/#{noteable[id_name]}/"\
               "discussions/#{diff_note.discussion_id}/notes", user), params: { body: 'hi!' }

      expect(response).to have_gitlab_http_status(:created)
      expect(json_response['body']).to eq('hi!')
      expect(json_response['type']).to eq('DiffNote')
    end
  end
end
