# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::RegistrationsHelper do
  using RSpec::Parameterized::TableSyntax

  describe '#in_subscription_flow?' do
    where(:user_return_to_path, :expected_result) do
      '/-/subscriptions/new?plan_id=bronze_plan' | true
      '/foo'                                     | false
      nil                                        | false
    end

    with_them do
      it 'returns the expected_result' do
        allow(helper).to receive(:session).and_return('user_return_to' => user_return_to_path)

        expect(helper.in_subscription_flow?).to eq(expected_result)
      end
    end
  end

  describe '#in_trial_flow?' do
    where(:user_return_to_path, :expected_result) do
      '/-/trials/new?glm_content=free-trial&glm_source=about.gitlab.com' | true
      '/foo'                                                             | false
      nil                                                                | false
    end

    with_them do
      it 'returns the expected_result' do
        allow(helper).to receive(:session).and_return('user_return_to' => user_return_to_path)

        expect(helper.in_trial_flow?).to eq(expected_result)
      end
    end
  end

  describe '#in_invitation_flow?' do
    where(:user_return_to_path, :expected_result) do
      '/-/invites/xxx' | true
      '/invites/xxx'   | false
      '/foo'           | false
      nil              | nil
    end

    with_them do
      it 'returns the expected_result' do
        allow(helper).to receive(:session).and_return('user_return_to' => user_return_to_path)

        expect(helper.in_invitation_flow?).to eq(expected_result)
      end
    end
  end

  describe '#in_oauth_flow?' do
    where(:user_return_to_path, :expected_result) do
      '/oauth/authorize?client_id=x&redirect_uri=y&response_type=code&state=z' | true
      '/foo'                                                                   | false
      nil                                                                      | nil
    end

    with_them do
      it 'returns the expected_result' do
        allow(helper).to receive(:session).and_return('user_return_to' => user_return_to_path)

        expect(helper.in_oauth_flow?).to eq(expected_result)
      end
    end
  end

  describe '#setup_for_company_label_text' do
    before do
      allow(helper).to receive(:in_subscription_flow?).and_return(in_subscription_flow)
      allow(helper).to receive(:in_trial_flow?).and_return(in_trial_flow)
    end

    subject { helper.setup_for_company_label_text }

    where(:in_subscription_flow, :in_trial_flow, :text) do
      true | true | 'Who will be using this GitLab subscription?'
      true | false | 'Who will be using this GitLab subscription?'
      false | true | 'Who will be using this GitLab trial?'
      false | false | 'Who will be using GitLab?'
    end

    with_them do
      it { is_expected.to eq(text) }
    end
  end

  describe '#visibility_level_options' do
    let(:user) { build(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      assign(:group, Group.new)
    end

    it 'returns the desired mapping' do
      expect(helper.visibility_level_options).to eq [
        { level: 0, label: 'Private', description: 'The group and its projects can only be viewed by members.' },
        { level: 10, label: 'Internal', description: 'The group and any internal projects can be viewed by any logged in user.' },
        { level: 20, label: 'Public', description: 'The group and any public projects can be viewed without any authentication.' }
      ]
    end
  end
end
