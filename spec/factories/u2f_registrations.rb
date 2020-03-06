# frozen_string_literal: true

FactoryBot.define do
  factory :u2f_registration do
    transient { device { U2F::FakeU2F.new(FFaker::BaconIpsum.characters(5)) } }
    certificate { Base64.strict_encode64(device.cert_raw) }
    key_handle { U2F.urlsafe_encode64(device.key_handle_raw) }
    public_key { Base64.strict_encode64(device.origin_public_key_raw) }
    counter { 0 }
  end
end
