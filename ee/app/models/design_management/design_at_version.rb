# frozen_string_literal: true

# Tuple of design and version
class DesignManagement::DesignAtVersion
  attr_accessor :version
  attr_accessor :design

  def initialize(design: nil, version: nil)
    @design, @version = design, version
  end

  def image
    @image ||= DesignManagement::ImageAtVersion.new(self)
  end
end
