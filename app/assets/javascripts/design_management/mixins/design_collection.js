import { propertyOf } from 'lodash';
import { s__ } from '~/locale';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import getDesignListQuery from '../graphql/queries/get_design_list.query.graphql';

export default {
  apollo: {
    designCollection: {
      query: getDesignListQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          iid: this.issueIid,
          atVersion: this.designsVersion,
        };
      },
      update: data => {
        const designCollection = propertyOf(data)(['project', 'issue', 'designCollection']);
        if (designCollection) {
          return designCollection;
        }
        return null;
      },
      result() {
        if (this.designCollection.copyState === 'ERROR') {
          createFlash(
            s__(
              'DesignManagement|There was an error moving your designs. Please upload your designs below.',
            ),
            'warning',
          );
        }
      },
    },
  },
  data() {
    return {
      designCollection: null,
    };
  },
};
