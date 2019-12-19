import design from '../mock_data/design';
import version from '../mock_data/version';

export const designUploadTransformation = {
  project: {
    __typename: 'Project',
    issue: {
      __typename: 'Issue',
      designCollection: {
        __typename: 'DesignCollection',
        designs: {
          __typename: 'DesignConnection',
          edges: [
            {
              __typename: 'DesignEdge',
              node: design,
            },
          ],
        },
        versions: { __typename: 'DesignVersionConnection', edges: [] },
      },
    },
  },
};

export const designDeletionTransformation = {
  project: {
    __typename: 'Project',
    issue: {
      __typename: 'Issue',
      designCollection: {
        __typename: 'DesignCollection',
        designs: {
          edges: [],
          __typename: 'DesignConnection',
        },
        versions: {
          edges: [],
          __typename: 'DesignVersionConnection',
        },
      },
    },
  },
};

export const newVersionTransformation = {
  project: {
    __typename: 'Project',
    issue: {
      __typename: 'Issue',
      designCollection: {
        __typename: 'DesignCollection',
        designs: {
          edges: [],
          __typename: 'DesignConnection',
        },
        versions: {
          edges: [
            {
              __typename: 'DesignVersionEdge',
              node: version,
            },
          ],
          __typename: 'DesignVersionConnection',
        },
      },
    },
  },
};

export const newDiscussionCommentTransformation = {
  project: {
    __typename: 'Project',
    issue: {
      __typename: 'Issue',
      designCollection: {
        __typename: 'DesignCollection',
        designs: {
          edges: [
            {
              id: 'design-id',
              filename: 'test.jpg',
              fullPath: 'full-design-path',
              image: 'test.jpg',
              updatedAt: '01-01-2019',
              updatedBy: { name: 'test' },
              notesCount: 2,
              discussions: {
                edges: [
                  {
                    node: {
                      id: 'discussion-id',
                      replyId: 'discussion-reply-id',
                      notes: {
                        edges: [
                          { node: { id: 'note-id', body: '123' } },
                          { __typename: 'NoteEdge', node: { id: 'note-id', body: '123' } },
                        ],
                      },
                    },
                  },
                ],
              },
              diffRefs: { headSha: 'headSha', baseSha: 'baseSha', startSha: 'startSha' },
            },
          ],
          __typename: 'DesignConnection',
        },
        versions: { edges: [], __typename: 'DesignVersionConnection' },
      },
    },
  },
};
