# frozen_string_literal: true

# Remove the default Devise length validation from the `User` model.

# This needs to be removed because the length validation provided by Devise does not
# support dynamically checking for min and max lengths.

# A new length validation has been added to `models/user.rb` instead, to keep supporting
# dynamic length validations, like:

# validates :password, length: { maximum: proc { password_length.max }, minimum: proc { password_length.min } }, allow_blank: true

# This can be removed as soon as https://github.com/plataformatec/devise/pull/5166
# is merged into Devise.

User._validators[:password].delete_if do |validator|
  validator.kind == :length &&
  validator.options[:minimum].is_a?(Integer) &&
  validator.options[:maximum].is_a?(Integer)
end
