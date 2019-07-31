# frozen_string_literal: true

module Ci
  class BuildNeed < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :build, class_name: "Ci::Build", foreign_key: :build_id, inverse_of: :needs

    validates :name, :build, presence: true, allow_blank: false

    scope :scoped_build, -> { where('ci_builds.id=ci_build_needs.build_id') }
  end
end
