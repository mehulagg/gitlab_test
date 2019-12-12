import { transformDesignUpload } from 'ee/design_management/graphql/cache/transformations';
import { designUploadTransformation } from '../mock_data';
import mockDesign from '../../mock_data/design';
import projectQuery from 'ee/design_management/graphql/queries/project.query.graphql';

describe('Apollo cache transformations', () => {
  describe('Design Upload', () => {
    const query = {
      query: projectQuery,
      variables: { fullPath: mockDesign.fullPath, iid: '1', atVersion: null },
    };
    const cacheData = {
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
    it('produces the correct transformation', () => {
      const transformed = transformDesignUpload(query, cacheData, { designs: [mockDesign] });
      expect(transformed).toEqual({ ...query, data: designUploadTransformation });
    });
  });
});
