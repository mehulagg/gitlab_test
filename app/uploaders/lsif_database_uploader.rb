# frozen_string_literal: true

class LsifDatabaseUploader < GitlabUploader
  include RecordsUploads::Concern
  include ObjectStorage::Concern
  prepend ObjectStorage::Extension::RecordsUploads
  include UploaderHelper

  attr_accessor :commit_id

  def initialize(project, commit_id)
    super(project)

    @commit_id = commit_id
  end

  def filename
    "lsif-dump-#{commit_id}.db"
  end

  private

  def dynamic_segment
    File.join(model.class.underscore, mounted_as.to_s, model.id.to_s)
  end
end
