# frozen_string_literal: true

module MergeRequestsUserArguments
  extend ActiveSupport::Concern

  class_methods do
    def user_mr_argument(role)
      user_mr_arguments << role

      argument :"#{role}_id", GraphQL::ID_TYPE, required: false,
        description: <<-DESC
        Global ID of a user. All resolved Merge Requests must have this user as #{role}.
        Incompatible with #{role}Username.
        DESC

      argument :"#{role}_username", GraphQL::STRING_TYPE, required: false,
        description: <<-DESC
        Username of a user. All resolved Merge Requests must have this user as #{role}.
        Incompatible with #{role}Id.
        DESC
    end

    def user_mr_arguments
      @user_mr_arguments ||= []
    end
  end

  def ready?(**args)
    self.class.user_mr_arguments.each do |role|
      ready_role_field(role, args)
    end

    super(**args)
  end

  def resolve(**args)
    self.class.user_mr_arguments.each do |role|
      apply_role_field(role, args)
    end

    super(**args)
  end

  private

  def ready_role_field(role, args)
    id_key = :"#{role}_id"
    username_key = :"#{role}_username"

    if args.has_key?(id_key) && args.has_key(username_key)
      raise ::Gitlab::Graphql::Errors::ArgumentError, "Incompatible arguments: #{id_key} and #{username_key}"
    end
  end

  def apply_role_field(role, args)
    user_id = args.delete(:"#{role}_id")
    username = args.delete(:"#{role}_username")

    user = UserFinder.new(user_id.presence || username).find_by_id_or_username
    user = nil unless Ability.allowed?(current_user, :read_user_profile, user)
    args[:"#{role}_id"] = user.id if user
  end
end
