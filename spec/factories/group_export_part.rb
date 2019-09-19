# frozen_string_literal: true

FactoryBot.define do
  factory :group_export_part, class: GroupExportPart do
    status :created
    association :export, factory: :group_export

    name 'attributes'
    params {
      {
        group_id: export.id,
        tmp_dir_path: 'tmp/dir/path'
      }
    }

    %i(created scheduled started finished failed aborted).each do |state|
      trait state do
        status state
      end
    end
  end
end
