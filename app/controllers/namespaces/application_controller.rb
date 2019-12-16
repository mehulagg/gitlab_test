# frozen_string_literal: true

module Namespaces
  class ApplicationController < ApplicationController
    skip_before_action :authenticate_user!
  end
end
