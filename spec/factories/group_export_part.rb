# frozen_string_literal: true

FactoryBot.define do
  factory :group_export_part, class: GroupExportPart do
    association :export, factory: :group_export

    status { 0 }
    name { 'attributes' }
    params do
      {
        group_id: export.id,
        tmp_dir_path: 'tmp/dir/path'
      }
    end

    trait :created do
      status { 0 }
    end

    trait :scheduled do
      status { 3 }
    end

    trait :started do
      status { 6 }
    end

    trait :finished do
      status { 9 }
    end

    trait :failed do
      status { -1 }
    end

    trait :aborted do
      status { -2 }
    end
  end
end
