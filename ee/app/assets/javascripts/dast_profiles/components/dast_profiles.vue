<script>
import * as Sentry from '@sentry/browser';
import { GlButton, GlTab, GlTabs } from '@gitlab/ui';
import { s__ } from '~/locale';
import ProfilesList from './dast_profiles_list.vue';
import dastSiteProfilesQuery from '../graphql/dast_site_profiles.query.graphql';
import dastSiteProfilesDelete from '../graphql/dast_site_profiles_delete.mutation.graphql';
import * as cacheUtils from '../graphql/cache_utils';

const profileTypes = [
  {
    key: 'siteProfiles',
    query: dastSiteProfilesQuery,
    mutation: dastSiteProfilesDelete,
    i18n: {
      label: s__('DastProfiles|Site Profiles'),
      errorMessages: {
        fetchNetworkError: s__(
          'DastProfiles|Could not fetch site profiles. Please refresh the page, or try again later.',
        ),
        deletionNetworkError: s__(
          'DastProfiles|Could not delete site profile. Please refresh the page, or try again later.',
        ),
        deletionBackendError: s__('DastProfiles|Could not delete site profiles:'),
      },
    },
  },
];

export default {
  components: {
    GlButton,
    GlTab,
    GlTabs,
    ProfilesList,
  },
  props: {
    newDastSiteProfilePath: {
      type: String,
      required: true,
    },
    projectFullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      siteProfiles: [],
      siteProfilesPageInfo: {},
      errorMessage: '',
      errorDetails: [],
    };
  },
  created() {
    this.$apollo.addSmartQuery(
      'siteProfiles',
      this.queryFactory({
        key: 'siteProfiles',
        query: dastSiteProfilesQuery,
        variables: {
          fullPath: this.projectFullPath,
          first: this.$options.profilesPerPage,
        },
      }),
    );
  },
  methods: {
    // TODO - check if we can move this to computed somehow
    hasMoreProfiles(key) {
      return this[`${key}PageInfo`].hasNextPage;
    },
    isLoadingProfiles(key) {
      return this.$apollo.queries[key].loading;
    },
    queryFactory({ key, query, variables }) {
      return {
        query,
        variables,
        result({ data, error }) {
          if (!error) {
            this[`${key}PageInfo`] = data.project[key].pageInfo;
          }
        },
        update(data) {
          const siteProfileEdges = data?.project?.[key]?.edges ?? [];

          return siteProfileEdges.map(({ node }) => node);
        },
        error(error) {
          this.handleError({
            exception: error,
            message: this.$options.i18n.errorMessages.fetchNetworkError,
          });
        },
      };
    },
    handleError({ exception, message = '', details = [] }) {
      Sentry.captureException(exception);
      this.errorMessage = message;
      this.errorDetails = details;
    },
    resetErrors() {
      this.errorMessage = '';
      this.errorDetails = [];
    },
    fetchMoreProfiles(key) {
      const {
        $apollo,
        siteProfilesPageInfo,
        $options: { i18n },
      } = this;

      this.resetErrors();

      $apollo.queries[key]
        .fetchMore({
          variables: { after: siteProfilesPageInfo.endCursor },
          updateQuery: cacheUtils.appendToPreviousResult,
        })
        .catch(error => {
          this.handleError({ exception: error, message: i18n.errorMessages.fetchNetworkError });
        });
    },
    deleteProfile(key, profileToBeDeletedId) {
      const {
        projectFullPath,
        handleError,
        $options: { i18n },
        $apollo: {
          queries: {
            [key]: { options: queryOptions },
          },
        },
      } = this;

      this.resetErrors();

      this.$apollo
        .mutate({
          mutation: dastSiteProfilesDelete,
          variables: {
            projectFullPath,
            profileId: profileToBeDeletedId,
          },
          update(
            store,
            {
              data: {
                dastSiteProfileDelete: { errors = [] },
              },
            },
          ) {
            if (errors.length === 0) {
              cacheUtils.removeProfile({
                store,
                queryBody: {
                  query: queryOptions.query,
                  variables: queryOptions.variables,
                },
                profileToBeDeletedId,
              });
            } else {
              handleError({
                message: i18n.errorMessages.deletionBackendError,
                details: errors,
              });
            }
          },
          optimisticResponse: cacheUtils.dastSiteProfilesDeleteResponse(),
        })
        .catch(error => {
          this.handleError({
            exception: error,
            message: i18n.errorMessages.deletionNetworkError,
          });
        });
    },
  },
  profilesPerPage: 10,
  i18n: {
    errorMessages: {
      fetchNetworkError: s__(
        'DastProfiles|Could not fetch site profiles. Please refresh the page, or try again later.',
      ),
      deletionNetworkError: s__(
        'DastProfiles|Could not delete site profile. Please refresh the page, or try again later.',
      ),
      deletionBackendError: s__('DastProfiles|Could not delete site profiles:'),
    },
  },
};
</script>

<template>
  <section>
    <header>
      <div class="gl-display-flex gl-align-items-center gl-pt-6 gl-pb-4">
        <h2 class="my-0">
          {{ s__('DastProfiles|Manage Profiles') }}
        </h2>
        <gl-button
          :href="newDastSiteProfilePath"
          category="primary"
          variant="success"
          class="gl-ml-auto"
        >
          {{ s__('DastProfiles|New Site Profile') }}
        </gl-button>
      </div>
      <p>
        {{
          s__(
            'DastProfiles|Save commonly used configurations for target sites and scan specifications as profiles. Use these with an on-demand scan.',
          )
        }}
      </p>
    </header>

    <gl-tabs>
      <gl-tab>
        <template #title>
          <span>{{ s__('DastProfiles|Site Profiles') }}</span>
        </template>

        <profiles-list
          :error-message="errorMessage"
          :error-details="errorDetails"
          :has-more-profiles-to-load="hasMoreProfiles('siteProfiles')"
          :is-loading="isLoadingProfiles('siteProfiles')"
          :profiles-per-page="$options.profilesPerPage"
          :profiles="siteProfiles"
          @loadMoreProfiles="fetchMoreProfiles('siteProfiles')"
          @deleteProfile="id => deleteProfile('siteProfiles', id)"
        />
      </gl-tab>
    </gl-tabs>
  </section>
</template>
