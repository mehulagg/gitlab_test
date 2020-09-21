# frozen_string_literal: true

require 'ipaddress'

# IpAddressValidator
#
# Validates that an IP address is a valid IPv4 or IPv6 address.
# This should be coupled with a database column of type `inet`
#
# When using column type `inet` Rails will silently return the value
# as `nil` when the value is not valid according to its type cast
# using `IpAddr`. It's not very user friendly to return an error
# "IP Address can't be blank" when a value was clearly given but
# was not the right format. This validator will look at the value
# before Rails type casts it when the value itself is `nil`.
# This enables the validator to return a specific and useful error message.
#
# Example:
#
#   class Group < ActiveRecord::Base
#     validates :ip_address, presence: true, ip_address: true
#   end
#
class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value = record.public_send("#{attribute}_before_type_cast") if value.nil? # rubocop:disable GitlabSecurity/PublicSend
    return if value.blank?

    IPAddress.parse(value.to_s)
  rescue
    record.errors.add(attribute, _('must be a valid IPv4 or IPv6 address'))
  end
end
