# frozen_string_literal: true

class Admin::Geo::ReplicablesController < Admin::Geo::ApplicationController
  before_action :check_license!
  before_action :set_replicator_class

  def index
  end

  private

  def set_replicator_class
    replicable_name = params[:plural_replicable_name].singularize

    @replicator_class = Gitlab::Geo::Replicator.for_replicable_name(replicable_name)
  end
end
