# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      module LabelReferenceFilter
        extend ::Gitlab::Utils::Override

        override :wrap_link
        def wrap_link(link, label)
          content = super
          # FIXME parent method defined for AbstracteferenceFilter depends on parent_type
          # which is not set when rendering epic's labels in notes
          parent = project || group
          if label.scoped_label? && parent.feature_available?(:scoped_labels)
            presenter = label.present(issuable_parent: parent)
            content = ::EE::LabelsHelper.scoped_label_wrapper(content, presenter)
          end

          content
        end

        def tooltip_title(label)
          ::EE::LabelsHelper.label_tooltip_title(label)
        end
      end
    end
  end
end
