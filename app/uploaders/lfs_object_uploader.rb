# frozen_string_literal: true

class LfsObjectUploader < GitlabUploader
  extend Workhorse::UploadPath
  include ObjectStorage::Concern
  include CarrierWave::MiniMagick

  storage_options Gitlab.config.lfs

  alias_method :upload, :model
  attr_accessor :enabled_version_namespaces

  # This forms a version namespace
  # (TODO move to EE)
  version :design_management, if: :generate_design_management_versions? do
    # These are the versions within the namespace
    version :small do
      # process resize_to_fill: [50,50]
      process resize_to_fit: [50, 50]
    end
  end

  def filename
    model.oid[4..-1]
  end

  def store_dir
    dynamic_segment
  end

  def enable_version_namespace(namespace)
    namespace = namespace.to_sym
    self.enabled_version_namespaces ||= []

    return if self.enabled_version_namespaces.include?(namespace)

    self.enabled_version_namespaces << namespace.to_sym
  end

  # Returns the same `LfsObjectUploader` instance with its #file set to
  # the given version.
  #
  # lfs_object.file.path
  #   # => file.png
  # lfs_object.version(:foo, :bar).path
  #   # => foo_bar_file.png
  def version(namespace, version)
    namespace, version = namespace.to_sym, version.to_sym
    raise "#{namespace} is not defined as a namespace" unless versions[namespace]
    raise "#{version} is not a version in #{namespace}" unless versions[namespace].versions.keys.include?(version)

    enable_version_namespace(namespace)
    send(namespace).send(version)
  end

  private

  def dynamic_segment
    File.join(model.oid[0, 2], model.oid[2, 2])
  end

  # TODO move to EE
  def generate_design_management_versions?(_picture)
    version_namespace_enabled?(:design_management)
  end

  def version_namespace_enabled?(namespace)
    return false unless enabled_version_namespaces

    enabled_version_namespaces.include?(namespace.to_sym)
  end
end
