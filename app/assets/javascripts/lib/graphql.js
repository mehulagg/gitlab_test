import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { createUploadLink } from 'apollo-upload-client';
import { ApolloLink } from 'apollo-link';
import { BatchHttpLink } from 'apollo-link-batch-http';
import { SchemaLink } from 'apollo-link-schema';
import { makeExecutableSchema } from 'graphql-tools';
import csrf from '~/lib/utils/csrf';

export const fetchPolicies = {
  CACHE_FIRST: 'cache-first',
  CACHE_AND_NETWORK: 'cache-and-network',
  NETWORK_ONLY: 'network-only',
  NO_CACHE: 'no-cache',
  CACHE_ONLY: 'cache-only',
};

export default (resolvers = {}, config = {}) => {
  let uri = `${gon.relative_url_root}/api/graphql`;

  if (config.baseUrl) {
    // Prepend baseUrl and ensure that `///` are replaced with `/`
    uri = `${config.baseUrl}${uri}`.replace(/\/{3,}/g, '/');
  }

  const httpOptions = {
    uri,
    headers: {
      [csrf.headerKey]: csrf.token,
    },
    // fetch won’t send cookies in older browsers, unless you set the credentials init option.
    // We set to `same-origin` which is default value in modern browsers.
    // See https://github.com/whatwg/fetch/pull/585 for more information.
    credentials: 'same-origin',
  };

  return new ApolloClient({
    link: ApolloLink.split(
      operation => operation.getContext().hasUpload || operation.getContext().isSingleRequest,
      createUploadLink(httpOptions),
      new BatchHttpLink(httpOptions),
    ),
    cache: new InMemoryCache({
      ...config.cacheConfig,
      freezeResults: config.assumeImmutableResults,
    }),
    resolvers,
    assumeImmutableResults: config.assumeImmutableResults,
    defaultOptions: {
      query: {
        fetchPolicy: config.fetchPolicy || fetchPolicies.CACHE_FIRST,
      },
    },
  });
};

export const createMockClient = (resolvers = {}, config = {}) => {
  const typeDefs = `
    type Milestone {
      id: ID!
      description: String
      title: String!
      state: String!
      dueDate: String
      startDate: String
      webUrl: String
    }

    type MilestoneEdge {
      node: Milestone!
    }

    type MilestoneConnection {
      edges: [MilestoneEdge!]!
    }

    type Group {
      id: ID!
      name: String!
      milestones: MilestoneConnection!
    }

    type Query {
      group: Group 
    }
  `;

  resolvers = {
    Query: {
      group: () => ({
        id: '123',
        name: 'Group name',
        milestones: {
          edges: [
            {
              node: {
                id: '1',
                title: 'Milestone 1',
                state: 'active',
                dueDate: '2020-02-03T10:15:30Z',
                startDate: '2020-01-03T10:15:30Z',
              },
            },
            {
              node: {
                id: '2',
                title: 'Milestone 2 blablablablablablabla',
                state: 'active',
                dueDate: '2020-02-15T10:15:30Z',
                startDate: '2020-01-17T10:15:30Z',
              },
            },
            {
              node: {
                id: '3',
                title: 'Milestone 3',
                state: 'active',
                dueDate: '2020-03-09T10:15:30Z',
                startDate: '2020-02-10T10:15:30Z',
                webUrl: 'www.google.com',
              },
            },
          ],
        },
      }),
    },
  };

  const executableSchema = makeExecutableSchema({
    typeDefs,
    resolvers,
  });

  const link = new SchemaLink({ schema: executableSchema });

  return new ApolloClient({
    link,
    cache: new InMemoryCache({
      ...config.cacheConfig,
      freezeResults: config.assumeImmutableResults,
    }),
    resolvers,
    assumeImmutableResults: config.assumeImmutableResults,
  });
};
