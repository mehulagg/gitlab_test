# frozen_string_literal: true

FactoryBot.define do
  factory :group_export, class: GroupExport do
    status :created
    association :group, factory: :group

    %i(created started finished failed).each do |state|
      trait state do
        status state
      end
    end
  end
end
