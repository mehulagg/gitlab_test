# frozen_string_literal: true

class IdentityVisitor < Scim::Kit::V2::Filter::Visitor
  MAPPINGS = {
    'id' => 'extern_uid',
    'externalId' => 'extern_uid'
  }.freeze

  def initialize(saml_provider)
    @saml_provider = saml_provider
  end

  def visit_equals(node)
    safely_run(:visit_equals) do
      query_for(expression_for(node, node.value), invert: node.not?)
    end
  end

  def visit_not_equals(node)
    safely_run(:visit_not_equals) do
      query_for(expression_for(node, node.value), invert: !node.not?)
    end
  end

  def visit_presence(node)
    safely_run(:visit_presence) do
      query_for(expression_for(node, nil), invert: !node.not?)
    end
  end

  def visit_and(node)
    visit(node.left).merge(visit(node.right))
  end

  def visit_or(node)
    visit(node.left).or(visit(node.right))
  end

  private

  attr_reader :saml_provider

  def attribute_for(node)
    MAPPINGS.fetch(node.attribute.to_s)
  end

  def safely_run(name)
    yield
  rescue KeyError
    raise error_for(name)
  end

  def query_for(conditions, invert: false)
    if invert
      saml_provider.identities.joins(:user).where.not(conditions)
    else
      saml_provider.identities.joins(:user).where(conditions)
    end
  end

  def username?(node)
    node.attribute.to_s == 'userName'
  end

  def expression_for(node, value)
    if username?(node)
      { users: { username: value } }
    else
      { attribute_for(node) => value }
    end
  end
end
