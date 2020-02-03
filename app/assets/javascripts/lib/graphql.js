import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { createUploadLink } from 'apollo-upload-client';
import { ApolloLink } from 'apollo-link';
import { BatchHttpLink } from 'apollo-link-batch-http';
import ActionCable from 'actioncable';
import ActionCableLink from 'graphql-ruby-client/subscriptions/ActionCableLink';
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
  };

  const cable = ActionCable.createConsumer();

  const hasSubscriptionOperation = ({ query: { definitions } }) => {
    return definitions.some(
      ({ kind, operation }) => kind === 'OperationDefinition' && operation === 'subscription',
    );
  };

  const link = ApolloLink.split(
    hasSubscriptionOperation,
    new ActionCableLink({ cable }),
    ApolloLink.split(
      operation => operation.getContext().hasUpload || operation.getContext().isSingleRequest,
      createUploadLink(httpOptions),
      new BatchHttpLink(httpOptions),
    ),
  );

  return new ApolloClient({
    link: link,
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
