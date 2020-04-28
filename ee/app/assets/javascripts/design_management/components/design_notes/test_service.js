import { defaultClient } from '../../graphql';
import getDesignQuery from '../../graphql/queries/getDesign.query.graphql';
import createNoteMutation from '../../graphql/mutations/createNote.mutation.graphql';
import { updateStoreAfterAddDiscussionComment } from '../../utils/cache_update';

export const sendCreateNoteMutation = (payload, designVariables, discussionId) => {
  return defaultClient.mutate({
    mutation: createNoteMutation,
    variables: { input: payload },
    update: (store, { data: { createNote } }) =>
      updateStoreAfterAddDiscussionComment(
        store,
        createNote,
        getDesignQuery,
        designVariables,
        discussionId,
      ),
  });
};

export default {};
