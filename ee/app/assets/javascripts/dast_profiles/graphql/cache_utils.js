/**
 * Appends paginated results to existing ones
 * - to be used with $apollo.queries.x.fetchMore
 *
 * @param key
 * @returns {function(*, {fetchMoreResult: *}): *}
 */
export const appendToPreviousResult = key => (previousResult, { fetchMoreResult }) => {
  const newResult = { ...fetchMoreResult };
  const previousEdges = previousResult.project[key].edges;
  const newEdges = newResult.project[key].edges;

  newResult.project[key].edges = [...previousEdges, ...newEdges];

  return newResult;
};

/**
 * Removes profile with given id from the cache and writes the result to it
 *
 * @param key
 * @param store
 * @param queryBody
 * @param profileToBeDeletedId
 */
export const removeProfile = ({ profileType, store, queryBody, profileToBeDeletedId }) => {
  const data = store.readQuery(queryBody);

  data.project[profileType].edges = data.project[profileType].edges.filter(({ node }) => {
    return node.id !== profileToBeDeletedId;
  });

  store.writeQuery({ ...queryBody, data });
};

/**
 * Returns an object representing a optimistic response for site-profile deletion
 *
 * @returns {{__typename: string, dastSiteProfileDelete: {__typename: string, errors: []}}}
 */
export const dastSiteProfilesDeleteResponse = () => ({
  // eslint-disable-next-line @gitlab/require-i18n-strings
  __typename: 'Mutation',
  dastSiteProfileDelete: {
    __typename: 'DastSiteProfileDeletePayload',
    errors: [],
  },
});
