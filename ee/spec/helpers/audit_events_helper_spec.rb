require 'spec_helper'

describe AuditEventsHelper do
  describe '#human_text' do
    let(:details) do
      {
        remove: 'user_access',
        author_name: 'John Doe',
        target_id: 1,
        target_type: 'User',
        target_details: 'Michael'
      }
    end

    it 'ignores keys that start with start with author_, or target_' do
      expect(human_text(details)).to eq 'Removed user access'
    end
  end
end
