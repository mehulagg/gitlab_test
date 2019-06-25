require 'spec_helper'

describe MailingList do
  describe "Associations" do
    it { is_expected.to belong_to :project }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:email) }
  end
end
