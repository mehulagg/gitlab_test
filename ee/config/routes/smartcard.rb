# frozen_string_literal: true

post 'smartcard/auth' => 'smartcard#auth'
get 'smartcard/extract_certificate' => 'smartcard#extract_certificate'
get 'smartcard/verify_certificate' => 'smartcard#verify_certificate'
