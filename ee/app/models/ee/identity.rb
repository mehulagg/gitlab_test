# frozen_string_literal: true

module EE
  module Identity
    extend ActiveSupport::Concern

    prepended do
      belongs_to :saml_provider

      validates :name_id, presence: true, if: :saml_provider

      validates :secondary_extern_uid,
        allow_blank: true,
        uniqueness: {
          scope: ::Identity::UniquenessScopes.scopes,
          case_sensitive: false
        }

      scope :with_secondary_extern_uid, ->(provider, secondary_extern_uid) do
        iwhere(secondary_extern_uid: normalize_uid(provider, secondary_extern_uid)).with_provider(provider)
      end

      def name_id
        extern_uid
      end
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      override :human_attribute_name
      def human_attribute_name(name, *args)
        if name.to_sym == :name_id
          "SAML NameID"
        else
          super
        end
      end

      def find_by_extern_uid(provider, extern_uid)
        with_extern_uid(provider, extern_uid).take
      end

      def find_by_group_saml_uid(saml_provider, extern_uid)
        where(provider: :group_saml,
              saml_provider: saml_provider,
              extern_uid: extern_uid).take
      end

      def preload_saml_group
        preload(saml_provider: { group: :route })
      end
    end
  end
end
