# frozen_string_literal: true

RSpec.configure do |config|
  config.include GonHelper, :gon

  config.before(:each, :gon) do
    Gon.clear
  end
end
