# frozen_string_literal: true

require 'spec_helper'

describe IssuableFinder::ByCommentersFinder do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:first_user) { create(:user) }
  let_it_be(:second_user) { create(:user) }

  shared_examples 'filter by commenters' do
    context 'filter by a single user' do
      let(:names) { [first_user.username] }
      let(:ids) { [first_user.id] }

      it 'returns issuables where the user commented' do
        expect(issuables_by_ids).to contain_exactly(only_first_issuable, both_issuable)
        expect(issuables_by_names).to contain_exactly(only_first_issuable, both_issuable)
      end
    end

    context 'filter by both users' do
      let(:names) { [first_user.username, second_user.username] }
      let(:ids) { [first_user.id, second_user.id] }

      it 'returns issuables where both users commented' do
        expect(issuables_by_ids).to contain_exactly(both_issuable)
        expect(issuables_by_names).to contain_exactly(both_issuable)
      end
    end

    context 'filter without passing any params' do
      let(:names) { [] }
      let(:ids) { [] }

      it 'returns all issuables' do
        expect(issuables_by_ids).to contain_exactly(only_first_issuable, both_issuable, other_issuable)
        expect(issuables_by_names).to contain_exactly(only_first_issuable, both_issuable, other_issuable)
      end
    end
  end

  def finder(klass, ids: nil, names: [])
    described_class.new(klass, names, ids).execute(klass.all)
  end

  def create_note(issuable, user)
    create(:note, noteable: issuable, project: project, author: user)
  end

  context 'filter issues' do
    it_behaves_like 'filter by commenters' do
      let_it_be(:only_first_issuable) { create(:issue, project: project) }
      let_it_be(:only_first_issuable_note) { create_note(only_first_issuable, first_user) }
      let_it_be(:both_issuable) { create(:issue, project: project) }
      let_it_be(:both_issuable_first_note) { create_note(both_issuable, first_user) }
      let_it_be(:both_issuable_second_note) { create_note(both_issuable, second_user) }
      let_it_be(:other_issuable) { create(:issue, project: project) }

      let(:issuables_by_ids) { finder(Issue, ids: ids) }
      let(:issuables_by_names) { finder(Issue, names: names) }
    end
  end

  context 'filter merge requests' do
    it_behaves_like 'filter by commenters' do
      let_it_be(:only_first_issuable) { create(:merge_request, source_branch: 'one', source_project: project) }
      let_it_be(:only_first_issuable_note) { create_note(only_first_issuable, first_user) }
      let_it_be(:both_issuable) { create(:merge_request, source_branch: 'two', source_project: project) }
      let_it_be(:both_issuable_first_note) { create_note(both_issuable, first_user) }
      let_it_be(:both_issuable_second_note) { create_note(both_issuable, second_user) }
      let_it_be(:other_issuable) { create(:merge_request, source_branch: 'three', source_project: project) }

      let(:issuables_by_ids) { finder(MergeRequest, ids: ids) }
      let(:issuables_by_names) { finder(MergeRequest, names: names) }
    end
  end
end
