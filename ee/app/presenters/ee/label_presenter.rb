# frozen_string_literal: true

module EE
  module LabelPresenter
    def presenter_scoped_label?
      label.scoped_label? && feature_subject.feature_available?(:scoped_labels)
    end

    def feature_subject
      issuable_subject || label.subject
    end
  end
end
