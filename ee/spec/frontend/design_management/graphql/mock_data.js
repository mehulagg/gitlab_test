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
