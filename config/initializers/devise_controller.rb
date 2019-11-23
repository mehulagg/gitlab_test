# frozen_string_literal: true

DeviseController.class_eval do
  # Overriding set_minimum_password_length from DeviseController.

  # Sets minimum password length to show to user
  def set_minimum_password_length
    @minimum_password_length = resource_class.password_length.min
  end
end
