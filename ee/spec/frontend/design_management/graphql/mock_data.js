import design from '../mock_data/design';

const designUploadTransformation = {
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

export default designUploadTransformation;
