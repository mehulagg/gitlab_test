import { transformDesignUpload } from 'ee/design_management/graphql/cache/transformations';
import { designUploadTransformation } from '../mock_data';
import mockDesign from '../../mock_data/design';

describe('Apollo cache transformations', () => {
  describe('Design Upload', () => {
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
      const transformed = transformDesignUpload(cacheData, { designs: [mockDesign] });
      expect(transformed).toEqual(designUploadTransformation);
    });
  });
});
