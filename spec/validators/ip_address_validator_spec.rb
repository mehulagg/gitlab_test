# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IpAddressValidator do
  let(:validator) { described_class.new(attributes: [:ip_address]) }
  let(:user) { build(:user) }

  def validate(value)
    validator.validate_each(user, :ip_address, value)
  end

  it 'adds an error when an invalid IP address is provided' do
    validate('invalid IP')

    expect(user.errors[:ip_address]).to eq(['must be a valid IPv4 or IPv6 address'])
  end

  it 'accepts a valid IPv4 address' do
    validate('192.168.17.43')

    expect(user.errors).to be_empty
  end

  it 'accepts a valid IPv6 address' do
    validate('2001:0db8:85a3:0000:0000:8a2e:0370:7334')

    expect(user.errors).to be_empty
  end
end
