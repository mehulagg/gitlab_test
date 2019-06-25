require 'spec_helper'

describe MailingListSubscriptions do
  describe "Associations" do
    it { is_expected.to belong_to :mailing_list }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:user_email) }
  end
end
