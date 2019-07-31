# frozen_string_literal: true

class ScimFinder
  attr_reader :saml_provider

  def initialize(group)
    @saml_provider = group&.saml_provider
  end

  def search(params)
    return Identity.none unless saml_provider&.enabled?

    parser = EE::Gitlab::Scim::ParamsParser.new(params)

    if parser.filter_operator == :eq
      if parser.filter_params[:extern_uid].present?
        Identity.where_group_saml_uid(saml_provider, parser.filter_params[:extern_uid])
      else
        #saml_provider.identities.filter_by_user_params(parser.filter_params)
        saml_provider.identities.joins(:user).where(users: parser.filter_params)
      end
    else
      Identity.all
    end
  end
end
