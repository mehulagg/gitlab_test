# frozen_string_literal: true

require 'spec_helper'

describe DeviseValidatable do
  describe 'User' do
    let_it_be(:existing_user) { create(:user) }

    context 'password' do
      it 'requires password to be set for a new record' do
        user = build(:user, password: '', password_confirmation: '')

        expect(user).to be_invalid
        expect(user.errors[:password].join).to eq('can\'t be blank')
      end

      it 'requires password_confirmation to be set for a new record' do
        user = build(:user, password: 'new_password', password_confirmation: 'something_else')

        expect(user).to be_invalid
        expect(user.errors[:password_confirmation].join).to eq('doesn\'t match Password')
      end

      it 'requires password to be set while updating/resetting password' do
        existing_user.password = ''
        existing_user.password_confirmation = ''

        expect(existing_user).to be_invalid
        expect(existing_user.errors[:password].join).to eq('can\'t be blank')
      end

      it 'requires password_confirmation to be set while updating/resetting password' do
        existing_user.password = 'set_new_password'
        existing_user.password_confirmation = 'something_else'

        expect(existing_user).to be_invalid
        expect(existing_user.errors[:password_confirmation].join).to eq('doesn\'t match Password')
      end

      it 'does not fail validations for password length when password is not changed' do
        existing_user.password = existing_user.password_confirmation = nil

        expect(existing_user).to be_valid
      end

      context 'password length' do
        before do
          expect(User).to receive(:password_length).twice.and_return(10..128)
        end

        it 'validates minimum password length' do
          user = build(:user, password: 'x' * 9, password_confirmation: 'x' * 9)

          expect(user).to be_invalid
          expect(user.errors[:password].join).to eq('is too short (minimum is 10 characters)')
        end

        it 'validates maximum password length' do
          user = build(:user, password: 'x' * 129, password_confirmation: 'x' * 129)

          expect(user).to be_invalid
          expect(user.errors[:password].join).to eq('is too long (maximum is 128 characters)')
        end

        it 'validates password length even if password is not required' do
          user = build(:user, password: 'x' * 129, password_confirmation: 'x' * 129)
          expect(user).to receive(:password_required?).twice.and_return(false)

          expect(user).to be_invalid
          expect(user.errors[:password].join).to eq('is too long (maximum is 128 characters)')
        end

        context 'min and max length values' do
          it 'matches the values set by the `password_length` method' do
            validators = User.validators_on :password
            length = validators.find { |v| v.kind == :length }

            assert_equal 10, length.options[:minimum].call
            assert_equal 128, length.options[:maximum].call
          end
        end
      end
    end

    context 'email' do
      it 'requires email to be set' do
        user = build(:user, email: nil)

        expect(user).to be_invalid
        expect(user.errors[:email].join).to eq('can\'t be blank')
      end

      it 'accepts valid formats' do
        %w(a.b.c@example.com test_mail@gmail.com any@any.net email@test.br 123@mail.test 1☃3@mail.test).each do |email|
          user = build(:user, email: email)

          expect(user).to be_valid
          expect(user.errors[:email]).to be_blank
        end
      end

      it 'is case-senstive' do
        user = build(:user, email: 'test@test.com')

        expect(user).to be_valid

        new_user = build(:user, email: 'TEST@TEST.COM')

        expect(new_user).to be_valid
        expect(new_user.errors[:email].join).to be_blank
      end

      context 'when email changes' do
        it 'validates uniqueness, allowing blank' do
          user = build(:user, email: '')

          expect(user).to be_invalid
          expect(user.errors[:email].join).not_to include('taken')

          user.email = existing_user.email

          expect(user).to be_invalid
          expect(user.errors[:email].join).to include('taken')
        end

        it 'validates format, allowing blank' do
          user = build(:user, email: '')

          expect(user).to be_invalid
          expect(user.errors[:email].join).not_to include('invalid')

          %w{invalid_email_format 123 $$$ () ☃}.each do |email|
            user.email = email
            expect(user).to be_invalid
            expect(user.errors[:email].join).to include('invalid')
          end
        end
      end
    end
  end
end
