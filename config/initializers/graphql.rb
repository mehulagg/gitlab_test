# frozen_string_literal: true

# Allow our GraphQL Types and Fields to accept `authorize` keywords
GraphQL::ObjectType.accepts_definitions(authorize: GraphQL::Define.assign_metadata_key(:authorize))
GraphQL::Field.accepts_definitions(authorize: GraphQL::Define.assign_metadata_key(:authorize))
GraphQL::Schema::Object.accepts_definition(:authorize)
GraphQL::Schema::Field.accepts_definition(:authorize)

# Allow our GraphQL Arguments to accept `complexity` keywords
GraphQL::Argument.accepts_definitions(complexity: GraphQL::Define.assign_metadata_key(:complexity))
GraphQL::Schema::Argument.accepts_definition(:complexity)

# TODO it'd be awesome if our resolvers could here too?
# TODO I wonder if we can validate complexity_type here? to only be set to certain things
# Allow our GraphQL Fields to accept `complexity_type` keywords
GraphQL::Field.accepts_definitions(complexity_type: GraphQL::Define.assign_metadata_key(:complexity_type))
GraphQL::Schema::Field.accepts_definition(:complexity_type)
