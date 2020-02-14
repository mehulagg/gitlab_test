# frozen_string_literal: true

module Analytics
  class InstanceActivity
    def pipelines_count
      pipeline_created_counter.get(source: :web) # TODO change to a regex \*\
    end

    def releases_count
      release_created_counter.get
    end
  end
end
