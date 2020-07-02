# frozen_string_literal: true

FactoryBot.modify do
  factory :group do
    trait :wiki_repo do
      after(:create) do |group|
        raise 'Failed to create wiki repository!' unless group.create_wiki
      end
    end

    trait :wiki_repo_with_files do
      wiki_repo

      transient do
        wiki_author { create(:user) }
      end

      after(:create) do |group, evaluator|
        group.wiki.repository.create_file(
          evaluator.wiki_author,
          "home.md",
          'The homepage',
          message: 'created home',
          branch_name: 'master')
        group.wiki.repository.create_file(
          evaluator.wiki_author,
          "file_two.md",
          'template_test',
          message: 'test 1',
          branch_name: 'master')
        group.wiki.repository.create_file(
          evaluator.wiki_author,
          "feature_proposal.md",
          'feature_proposal',
          message: 'test 2',
          branch_name: 'master')
      end
    end
  end
end

FactoryBot.define do
  factory :group_with_members, parent: :group do
    after(:create) do |group, evaluator|
      group.add_developer(create(:user))
    end
  end

  factory :group_with_ldap, parent: :group do
    transient do
      cn { 'group1' }
      group_access { Gitlab::Access::GUEST }
      provider { 'ldapmain' }
    end

    factory :group_with_ldap_group_link do
      after(:create) do |group, evaluator|
        group.ldap_group_links << create(
          :ldap_group_link,
            cn: evaluator.cn,
            group_access: evaluator.group_access,
            provider: evaluator.provider
        )
      end
    end

    factory :group_with_ldap_group_filter_link do
      after(:create) do |group, evaluator|
        group.ldap_group_links << create(
          :ldap_group_link,
            filter: '(a=b)',
            cn: nil,
            group_access: evaluator.group_access,
            provider: evaluator.provider
        )
      end
    end
  end

  factory :group_with_deletion_schedule, parent: :group do
    transient do
      deleting_user { create(:user) }
      marked_for_deletion_on { nil }
    end

    after(:create) do |group, evaluator|
      create(:group_deletion_schedule,
        group: group,
        deleting_user: evaluator.deleting_user,
        marked_for_deletion_on: evaluator.marked_for_deletion_on
      )
    end
  end

  factory :group_with_managed_accounts, parent: :group do
    after(:create) do |group, evaluator|
      create(:saml_provider,
        :enforced_group_managed_accounts,
        group: group)
    end
  end

  factory :group_with_plan, parent: :group do
    transient do
      plan { :default_plan }
      trial_ends_on { nil }
    end

    after(:create) do |group, evaluator|
      if evaluator.plan
        create(:gitlab_subscription,
               namespace: group,
               hosted_plan: create(evaluator.plan),
               trial: evaluator.trial_ends_on.present?,
               trial_ends_on: evaluator.trial_ends_on)
      end
    end
  end
end
