# frozen_string_literal: true

module Ci
  class Result < ApplicationRecord
    extend Gitlab::Ci::Model

    validates_presence_of :name

    belongs_to :job, class_name: "Ci::Build", foreign_key: :job_id
  end
end
