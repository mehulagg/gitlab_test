import createFlash from '~/flash';
import { extractDesign } from './design_management_utils';
import { ADD_IMAGE_DIFF_NOTE_ERROR } from './error_messages';

const addImageDiffNoteToStore = (store, createImageDiffNote, query, variables) => {
  const data = store.readQuery({
    query,
    variables,
  });
  const newDiscussion = {
    __typename: 'DiscussionEdge',
    node: {
      // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
      // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
      __typename: 'Discussion',
      id: createImageDiffNote.note.discussion.id,
      replyId: createImageDiffNote.note.discussion.replyId,
      notes: {
        __typename: 'NoteConnection',
        edges: [
          {
            __typename: 'NoteEdge',
            node: createImageDiffNote.note,
          },
        ],
      },
    },
  };
  const design = extractDesign(data);
  const notesCount = design.notesCount + 1;
  design.discussions.edges = [...design.discussions.edges, newDiscussion];
  if (
    !design.issue.participants.edges.some(
      participant => participant.node.username === createImageDiffNote.note.author.username,
    )
  ) {
    design.issue.participants.edges = [
      ...design.issue.participants.edges,
      {
        __typename: 'UserEdge',
        node: {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          __typename: 'User',
          ...createImageDiffNote.note.author,
        },
      },
    ];
  }
  store.writeQuery({
    query,
    variables,
    data: {
      ...data,
      design: {
        ...design,
        notesCount,
      },
    },
  });
};

const onError = (data, message) => {
  createFlash(message);
  throw new Error(data.errors);
};

export const updateStoreAfterAddImageDiffNote = (store, data, query, queryVariables) => {
  if (data.errors) {
    onError(data, ADD_IMAGE_DIFF_NOTE_ERROR);
  } else {
    addImageDiffNoteToStore(store, data, query, queryVariables);
  }
};
