# frozen_string_literal: true

class ScimFinder
  attr_reader :saml_provider

  UnsupportedFilter = Class.new(StandardError)

  def initialize(group)
    @saml_provider = group&.saml_provider
  end

  def search(params)
    return Identity.none unless saml_provider&.enabled?
    return saml_provider.identities if unfiltered?(params)

    filter_identities(params)
  end

  private

  def unfiltered?(params)
    params[:filter].blank?
  end

  def filter_identities(params)
    parser = EE::Gitlab::Scim::ParamsParser.new(params)

    if eq_filter_on_extern_uid?(parser)
      by_extern_uid(parser.filter_params[:extern_uid])
    elsif eq_filter_on_username?(parser)
      identity = by_extern_uid(parser.filter_params[:username])
      return identity if identity.present?

      by_username(parser.filter_params[:username])
    else
      raise UnsupportedFilter
    end
  end

  def eq_filter_on_extern_uid?(parser)
    parser.filter_operator == :eq && parser.filter_params[:extern_uid].present?
  end

  def by_extern_uid(extern_uid)
    Identity.where_group_saml_uid(saml_provider, extern_uid)
  end

  def eq_filter_on_username?(parser)
    parser.filter_operator == :eq && parser.filter_params[:username].present?
  end

  def by_username(username)
    return [] unless user = User.find_by_username(username)

    saml_provider.identities.for_user(user)
  end
end
