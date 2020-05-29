# frozen_string_literal: true

module Ci
  class InstanceVariablePresenter < Gitlab::View::Presenter::Delegated
    presents :variable

    def placeholder
      'INSTANCE_LEVEL_VARIABLE'
    end

    def form_path
      ci_cd_admin_application_settings_path
    end

    def edit_path
      admin_ci_variables_path
    end

    def delete_path
      admin_ci_variables_path
    end
  end
end
