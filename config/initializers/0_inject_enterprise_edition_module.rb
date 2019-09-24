# frozen_string_literal: true

require 'active_support/inflector'

module InjectEnterpriseEditionModule
  def prepend_if_ee(constant, with_descendants: false)
    return unless Gitlab.ee?

    ee_module = constant.constantize
    prepend(ee_module)

    if with_descendants
      descendants.each { |descendant| descendant.prepend(ee_module) }
    end
  end

  def extend_if_ee(constant)
    extend(constant.constantize) if Gitlab.ee?
  end

  def include_if_ee(constant)
    include(constant.constantize) if Gitlab.ee?
  end

  def prepend_if_com(constant, with_descendants: false)
    return unless Gitlab.com?

    com_module = constant.constantize
    prepend(com_module)

    if with_descendants
      descendants.each { |descendant| descendant.prepend(com_module) }
    end
  end
end

Module.prepend(InjectEnterpriseEditionModule)
