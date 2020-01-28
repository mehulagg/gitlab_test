# frozen_string_literal: true

module GonHelper
  def gon
    RequestStore.store[:gon].gon
  end
end
