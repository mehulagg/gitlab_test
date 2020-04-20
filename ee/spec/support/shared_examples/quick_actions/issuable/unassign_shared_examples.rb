# frozen_string_literal: true

RSpec.shared_examples 'unassigning a not assigned user' do |is_multiline|
  before do
    target.assignees = [assignee]
  end

  it 'adds multiple assignees from the list' do
    response = service.execute(note)

    expected_message = is_multiline ? "Removed assignee @#{assignee.username}. Removed assignee @#{user.username}." : "Removed assignees @#{user.username} and @#{assignee.username}."

    expect(response.messages).to eq(expected_message)
    expect { described_class.apply_updates(response, note) }.not_to raise_error
  end
end
