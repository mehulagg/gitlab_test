# frozen_string_literal: true

# LDAPFilteralidator
#
# Custom validator for LDAP filters
#
# Example:
#
#   class LDAPGroupLink < ActiveRecord::Base
#     validates :filter, ldap_filter: true
#   end
#
class LDAPFilterValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Net::LDAP::Filter::FilterParser.parse(value)
  rescue Net::LDAP::FilterSyntaxInvalidError
    record.errors.add(attribute, 'must be a valid filter')
  end
end
