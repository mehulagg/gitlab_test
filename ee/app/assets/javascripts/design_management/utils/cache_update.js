import createFlash from '~/flash';
import { extractCurrentDiscussion, extractDesign } from './design_management_utils';
import { ADD_IMAGE_DIFF_NOTE_ERROR, ADD_DISCUSSION_COMMENT_ERROR } from './error_messages';

const addDiscussionCommentToStore = (store, createNote, query, queryVariables, discussionId) => {
  const data = store.readQuery({
    query,
    variables: queryVariables,
  });

  const design = extractDesign(data);
  const currentDiscussion = extractCurrentDiscussion(design.discussions, discussionId);
  currentDiscussion.node.notes.edges = [
    ...currentDiscussion.node.notes.edges,
    {
      __typename: 'NoteEdge',
      node: createNote.note,
    },
  ];

  design.notesCount += 1;
  if (
    !design.issue.participants.edges.some(
      participant => participant.node.username === createNote.note.author.username,
    )
  ) {
    design.issue.participants.edges = [
      ...design.issue.participants.edges,
      {
        __typename: 'UserEdge',
        node: {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          __typename: 'User',
          ...createNote.note.author,
        },
      },
    ];
  }
  store.writeQuery({
    query,
    variables: queryVariables,
    data: {
      ...data,
      design: {
        ...design,
      },
    },
  });
};

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

export const updateStoreAfterAddDiscussionComment = (
  store,
  data,
  query,
  queryVariables,
  discussionId,
) => {
  if (data.errors) {
    onError(data, ADD_DISCUSSION_COMMENT_ERROR);
  } else {
    addDiscussionCommentToStore(store, data, query, queryVariables, discussionId);
  }
};

export const updateStoreAfterAddImageDiffNote = (store, data, query, queryVariables) => {
  if (data.errors) {
    onError(data, ADD_IMAGE_DIFF_NOTE_ERROR);
  } else {
    addImageDiffNoteToStore(store, data, query, queryVariables);
  }
};
