# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UserAccess do
  include ExternalAuthorizationServiceHelpers

  let(:user) { create(:user) }
  let(:access) { described_class.new(user, container: project) }

  describe '#can_push_to_branch?' do
    context 'for a group wiki' do
      let(:group) { create(:group, :wiki_repo_with_files) }
      let(:access) { described_class.new(user, container: group.wiki) }

      it 'returns true if user is a maintainer' do
        group.add_maintainer(user)

        expect(access.can_push_to_branch?('random_branch')).to be_truthy
      end

      it 'returns true if user is a developer' do
        group.add_developer(user)

        expect(access.can_push_to_branch?('random_branch')).to be_truthy
      end

      it 'returns false if user is a reporter' do
        group.add_reporter(user)

        expect(access.can_push_to_branch?('random_branch')).to be_falsey
      end

      describe 'push to empty group wiki' do
        let(:group) { create(:group, :wiki_repo) }

        it 'returns true for admins' do
          user.update!(admin: true)

          expect(access.can_push_to_branch?('master')).to be_truthy
        end

        it 'returns true if user is maintainer' do
          group.add_maintainer(user)

          expect(access.can_push_to_branch?('master')).to be_truthy
        end

        context 'when the user is a developer' do
          using RSpec::Parameterized::TableSyntax

          before do
            group.add_developer(user)
          end

          where(:default_branch_protection_level, :result) do
            Gitlab::Access::PROTECTION_NONE          | true
            Gitlab::Access::PROTECTION_DEV_CAN_PUSH  | true
            Gitlab::Access::PROTECTION_DEV_CAN_MERGE | false
            Gitlab::Access::PROTECTION_FULL          | false
          end

          with_them do
            it do
              expect(group).to receive(:default_branch_protection).and_return(default_branch_protection_level).at_least(:once)

              expect(access.can_push_to_branch?('master')).to eq(result)
            end
          end
        end
      end
    end

    describe 'push to empty project' do
      let(:project) { create(:project_empty_repo) }

      it 'returns false when the external service denies access' do
        project.add_maintainer(user)
        external_service_deny_access(user, project)

        expect(access.can_push_to_branch?('master')).to be_falsey
      end
    end
  end
end
