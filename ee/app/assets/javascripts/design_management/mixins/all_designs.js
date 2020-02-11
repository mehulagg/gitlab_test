/* eslint no-param-reassign: ["error", { "props": false }] */

import { get } from 'lodash';
import produce from 'immer';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import projectQuery from '../graphql/queries/project.query.graphql';
import { extractNodes, DESIGNS_PAGE_SIZE } from '../utils/design_management_utils';
import allVersionsMixin from './all_versions';
import { DESIGNS_ROUTE_NAME } from '../router/constants';

export default {
  mixins: [allVersionsMixin],
  apollo: {
    designs: {
      query: projectQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          iid: this.issueIid,
          atVersion: this.designsVersion,
          first: DESIGNS_PAGE_SIZE,
        };
      },
      update: data => {
        const designEdges = get(data, ['project', 'issue', 'designCollection', 'designs']);
        if (designEdges) {
          return extractNodes(designEdges);
        }
        return [];
      },
      error() {
        this.error = true;
      },
      result(res) {
        this.pageInfo = res.data?.project?.issue?.designCollection?.designs?.pageInfo;
        this.totalCount = res.data?.project?.issue?.designCollection?.designs?.totalCount;
        if (this.$route.query.version && !this.hasValidVersion) {
          createFlash(
            s__(
              'DesignManagement|Requested design version does not exist. Showing latest version instead',
            ),
          );
          this.$router.replace({ name: DESIGNS_ROUTE_NAME, query: { version: undefined } });
        }
      },
    },
  },
  data() {
    return {
      designs: [],
      error: false,
      pageInfo: null,
      totalCount: 0,
    };
  },
  methods: {
    fetchMoreDesigns() {
      if (this.pageInfo?.hasNextPage)
        this.$apollo.queries.designs.fetchMore({
          variables: {
            fullPath: this.projectPath,
            iid: this.issueIid,
            atVersion: this.designsVersion,
            first: DESIGNS_PAGE_SIZE,
            after: this.pageInfo?.endCursor,
          },
          updateQuery(previousResult, { fetchMoreResult }) {
            const newResult = produce(previousResult, draftResult => {
              const draftDesigns = draftResult.project.issue.designCollection.designs;
              const newDesigns = fetchMoreResult.project.issue.designCollection.designs;
              draftDesigns.edges.push(...newDesigns.edges);
              draftDesigns.pageInfo = newDesigns.pageInfo;
            });

            return newResult;
          },
        });
    },
  },
};
