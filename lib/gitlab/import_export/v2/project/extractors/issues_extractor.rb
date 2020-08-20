# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Extractors
  class IssuesExtractor
    IssuesQuery = ::Gitlab::ImportExport::V2::Project::Graphql::Client.parse <<-'GRAPHQL'
      query($project: ID!) {
        project(fullPath:$project) {
            issues(first: 1) {
              edges {
                node {
                  assignees {
                    edges {
                      node {
                        email
                      }
                    }
                  }
                  discussions {
                    edges {
                      node {
                        id
                        notes {
                          edges {
                            node {
                              body
                              system
                              confidential
                              author {
                                email
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  author {
                    email
                  }
                  createdAt
                  closedAt
                  confidential
                  createdAt
                  description
                  discussionLocked
                  dueDate
                  healthStatus
                  relativePosition
                  state
                  statusPagePublishedIncident
                  timeEstimate
                  title
                  type
                  updatedAt
                  weight
                }
              }
            }
          }
      }
    GRAPHQL

    def extract(project:)
      ::Gitlab::ImportExport::V2::Project::Graphql::Client
        .query(IssuesQuery, variables: { project: project })
        .original_hash
    end
  end
end
