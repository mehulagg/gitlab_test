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

    Scim::Kit::V2::Filter
      .parse(params[:filter])
      .accept(IdentityVisitor.new(saml_provider))
  rescue Scim::Kit::NotImplementedError, ::Parslet::ParseFailed
    raise UnsupportedFilter
  end

  private

  def unfiltered?(params)
    params[:filter].blank?
  end
end
