import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { uniqueId } from 'lodash';
import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import axios from '~/lib/utils/axios_utils';
import createDefaultClient from '~/lib/graphql';
import activeDiscussionQuery from './graphql/queries/active_discussion.query.graphql';
import getDesignQuery from './graphql/queries/get_design.query.graphql';
import typeDefs from './graphql/typedefs.graphql';
import { addPendingTodoToStore } from './utils/cache_update';

Vue.use(VueApollo);

const resolvers = {
  Mutation: {
    updateActiveDiscussion: (_, { id = null, source }, { cache }) => {
      const data = cache.readQuery({ query: activeDiscussionQuery });
      data.activeDiscussion = {
        __typename: 'ActiveDiscussion',
        id,
        source,
      };
      cache.writeQuery({ query: activeDiscussionQuery, data });
    },
    createDesignTodo: (
      _,
      {
        project_path: projectPath = null,
        issuable_id = null,
        target_design_id: targetDesignId = null,
      },
      { cache },
    ) => {
      return axios
        .post(`/${projectPath}/todos`, {
          issuable_id,
          issuable_type: 'issue',
          // target_design_id: targetDesignId,
        })
        .then(data => {
          const todo = data; // TODO check if this is correct (probably isnt)
          addPendingTodoToStore(cache, todo, getDesignQuery, {
            fullPath: projectPath,
            iid: issuable_id,
            filenames: [targetDesignId], // TODO this might not be correct
            // atVersion: null,
          });
        });
    },
  },
};

const defaultClient = createDefaultClient(
  resolvers,
  // This config is added temporarily to resolve an issue with duplicate design IDs.
  // Should be removed as soon as https://gitlab.com/gitlab-org/gitlab/issues/13495 is resolved
  {
    cacheConfig: {
      dataIdFromObject: object => {
        // eslint-disable-next-line no-underscore-dangle, @gitlab/require-i18n-strings
        if (object.__typename === 'Design') {
          return object.id && object.image ? `${object.id}-${object.image}` : uniqueId();
        }
        return defaultDataIdFromObject(object);
      },
    },
    typeDefs,
  },
);

export default new VueApollo({
  defaultClient,
});
