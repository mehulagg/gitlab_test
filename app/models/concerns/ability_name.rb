# frozen_string_literal: true

module AbilityName
  def to_ability_name
    model_name.singular
  end
end
