export default {
  note: {
    discussion: {
      id: 'gid://gitlab/DiffDiscussion/ff54aea8c2b0e2b5e84de42f11ad96c428c75679',
      replyId: 'gid://gitlab/DiffDiscussion/ff54aea8c2b0e2b5e84de42f11ad96c428c75679',
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
  __typename: 'CreateImageDiffNotePayload',
};
