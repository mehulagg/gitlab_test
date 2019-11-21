# frozen_string_literal: true

class Projects::LogsController < Projects::ApplicationController
end

Projects::LogsController.prepend_if_ee('EE::Projects::LogsController')
