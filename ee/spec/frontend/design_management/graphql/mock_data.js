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
              __typename: 'DesignEdge',
              node: {
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
            },
          ],
          __typename: 'DesignConnection',
        },
        versions: { edges: [], __typename: 'DesignVersionConnection' },
      },
    },
  },
};

export const newImageDiffNoteTransformation = {
  project: {
    __typename: 'Project',
    issue: {
      __typename: 'Issue',
      designCollection: {
        __typename: 'DesignCollection',
        designs: {
          edges: [
            {
              __typename: 'DesignEdge',
              node: {
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
                        notes: { edges: [{ node: { id: 'note-id', body: '123' } }] },
                      },
                    },
                    {
                      __typename: 'DiscussionEdge',
                      node: {
                        __typename: 'Discussion',
                        id: 'gid://gitlab/DiffDiscussion/ff54aea8c2b0e2b5e84de42f11ad96c428c75679',
                        replyId:
                          'gid://gitlab/DiffDiscussion/ff54aea8c2b0e2b5e84de42f11ad96c428c75679',
                        notes: {
                          __typename: 'NoteConnection',
                          edges: [
                            {
                              __typename: 'NoteEdge',
                              node: {
                                discussion: {
                                  id:
                                    'gid://gitlab/DiffDiscussion/ff54aea8c2b0e2b5e84de42f11ad96c428c75679',
                                  replyId:
                                    'gid://gitlab/DiffDiscussion/ff54aea8c2b0e2b5e84de42f11ad96c428c75679',
                                  notes: {
                                    edges: [
                                      {
                                        node: {
                                          __typename: 'Note',
                                          id: 'gid://gitlab/DiffNote/1709',
                                          author: {
                                            avatarUrl:
                                              'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
                                            name: 'Administrator',
                                            username: 'root',
                                            webUrl: 'http://0.0.0.0:3000/root',
                                            __typename: 'User',
                                          },
                                          body: 'asdd',
                                          bodyHtml:
                                            '<p data-sourcepos="1:1-1:4" dir="auto">asdd</p>',
                                          createdAt: '2019-12-19T04:59:28Z',
                                          position: {
                                            diffRefs: {
                                              __typename: 'DiffRefs',
                                              baseSha: '298036ddbabb220c36f92d079597a3f6aa39ac4a',
                                              startSha: '298036ddbabb220c36f92d079597a3f6aa39ac4a',
                                              headSha: '6bb83b156a016f6f6877377179b2ffe61d282277',
                                            },
                                            x: 369,
                                            y: 456,
                                            height: 843,
                                            width: 694,
                                            __typename: 'DiffPosition',
                                          },
                                        },
                                        __typename: 'NoteEdge',
                                      },
                                    ],
                                    __typename: 'NoteConnection',
                                  },
                                  __typename: 'Discussion',
                                },
                                __typename: 'Note',
                                id: 'gid://gitlab/DiffNote/1709',
                                author: {
                                  avatarUrl:
                                    'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
                                  name: 'Administrator',
                                  username: 'root',
                                  webUrl: 'http://0.0.0.0:3000/root',
                                  __typename: 'User',
                                },
                                body: 'asdd',
                                bodyHtml: '<p data-sourcepos="1:1-1:4" dir="auto">asdd</p>',
                                createdAt: '2019-12-19T04:59:28Z',
                                position: {
                                  diffRefs: {
                                    __typename: 'DiffRefs',
                                    baseSha: '298036ddbabb220c36f92d079597a3f6aa39ac4a',
                                    startSha: '298036ddbabb220c36f92d079597a3f6aa39ac4a',
                                    headSha: '6bb83b156a016f6f6877377179b2ffe61d282277',
                                  },
                                  x: 369,
                                  y: 456,
                                  height: 843,
                                  width: 694,
                                  __typename: 'DiffPosition',
                                },
                              },
                            },
                          ],
                        },
                      },
                    },
                  ],
                },
                diffRefs: { headSha: 'headSha', baseSha: 'baseSha', startSha: 'startSha' },
              },
            },
          ],
          __typename: 'DesignConnection',
        },
        versions: { edges: [], __typename: 'DesignVersionConnection' },
      },
    },
  },
};
