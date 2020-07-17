import initIssuableSidebar from '~/init_issuable_sidebar';
import Issue from '~/issue';
import ShortcutsIssuable from '~/behaviors/shortcuts/shortcuts_issuable';
import ZenMode from '~/zen_mode';
import '~/notes/index';
import initIssueableApp, { issuableHeaderWarnings } from '~/issue_show';
import initSentryErrorStackTraceApp from '~/sentry_error_stack_trace';
import initRelatedMergeRequestsApp from '~/related_merge_requests';
import initVueIssuableSidebarApp from '~/issuable_sidebar/sidebar_bundle';
import gql from 'graphql-tag';
import VueApollo from 'vue-apollo';
import getIssueDataQuery from '~/issue_show/queries/get_issue_data.query.graphql';
import createDefaultClient from '~/lib/graphql';

export default function() {
  const typeDefs = gql`
    type Mutation {
      toggleIssue(id: ID!): Boolean
    }
  `;

  const resolvers = {
    Mutation: {
      toggleIssue: (_, __, { cache }) => {
        const data = cache.readQuery({ query: getIssueDataQuery });
        data.project.issue.state = data.project.issue.state === 'closed' ? 'open' : 'closed';
        cache.writeQuery({ query: getIssueDataQuery, data });
        return data;
      },
    },
  };

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(resolvers, { typeDefs }),
  });

  initIssueableApp(apolloProvider);
  initSentryErrorStackTraceApp();
  initRelatedMergeRequestsApp(apolloProvider);
  issuableHeaderWarnings();

  import(/* webpackChunkName: 'design_management' */ '~/design_management')
    .then(module => module.default())
    .catch(() => {});

  // This will be removed when we remove the `design_management_moved` feature flag
  // See https://gitlab.com/gitlab-org/gitlab/-/issues/223197
  import(/* webpackChunkName: 'design_management' */ '~/design_management_new')
    .then(module => module.default())
    .catch(() => {});

  new Issue(); // eslint-disable-line no-new
  new ShortcutsIssuable(); // eslint-disable-line no-new
  new ZenMode(); // eslint-disable-line no-new
  if (gon.features && gon.features.vueIssuableSidebar) {
    initVueIssuableSidebarApp();
  } else {
    initIssuableSidebar();
  }
}
