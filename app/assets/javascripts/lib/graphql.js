import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { createUploadLink } from 'apollo-upload-client';
import { ApolloLink } from 'apollo-link';
import { BatchHttpLink } from 'apollo-link-batch-http';
import { persistCache } from 'apollo-cache-persist';
import localforage from 'localforage';
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
  const cache = new InMemoryCache({
    ...config.cacheConfig,
    freezeResults: config.assumeImmutableResults,
  });

  if (config.persist) {
    localforage.config({
      version: config.persist.version,
      storeName: 'apollo',
    });

    persistCache({
      cache,
      storage: localforage,
      key: config.persist.key,
      debug: true,
    });
  }

  return new ApolloClient({
    link: ApolloLink.split(
      operation => operation.getContext().hasUpload || operation.getContext().isSingleRequest,
      createUploadLink(httpOptions),
      new BatchHttpLink(httpOptions),
    ),
    cache,
    resolvers,
    assumeImmutableResults: config.assumeImmutableResults,
    defaultOptions: {
      query: {
        fetchPolicy: config.fetchPolicy || fetchPolicies.CACHE_FIRST,
      },
    },
  });
};
