<script>
import * as Sentry from '@sentry/browser';
import { GlButton, GlTab, GlTabs } from '@gitlab/ui';
import { s__ } from '~/locale';
import ProfilesList from './dast_profiles_list.vue';
import dastSiteProfilesQuery from '../graphql/dast_site_profiles.query.graphql';
import dastScannerProfilesQuery from '../graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesDelete from '../graphql/dast_site_profiles_delete.mutation.graphql';
import dastScannerProfilesDelete from '../graphql/dast_scanner_profiles_delete.mutation.graphql';
import * as cacheUtils from '../graphql/cache_utils';

const configs = [
  {
    profileType: 'siteProfiles',
    query: dastSiteProfilesQuery,
    deleteMutation: dastSiteProfilesDelete,
    isEnabled: () => true, // feature flags can be passed in
    fields: ['profileName', 'targetUrl'],
    i18n: {
      title: s__('DastProfiles|Site Profiles'),
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
  {
    profileType: 'scannerProfiles',
    query: dastScannerProfilesQuery,
    deleteMutation: dastScannerProfilesDelete,
    isEnabled: () => true, // feature flags can be passed in
    fields: ['profileName', 'scannerType'],
    i18n: {
      title: s__('DastProfiles|Scanner Profiles'),
      errorMessages: {
        fetchNetworkError: s__(
          'DastProfiles|Could not fetch scanner profiles. Please refresh the page, or try again later.',
        ),
        deletionNetworkError: s__(
          'DastProfiles|Could not delete scanner profile. Please refresh the page, or try again later.',
        ),
        deletionBackendError: s__('DastProfiles|Could not delete scanner profiles:'),
      },
    },
  },
];

export default {
  configs,
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
      scannerProfiles: {},
      siteProfiles: {},
      errorMessage: '',
      errorDetails: [],
    };
  },
  created() {
    this.addSmartQueriesForEnabledProfileTypes();
  },
  methods: {
    getEnabledProfileConfigs() {
      return this.$options.configs.filter(({ isEnabled }) => isEnabled());
    },
    addSmartQueriesForEnabledProfileTypes() {
      this.getEnabledProfileConfigs().forEach(({ profileType, query }) => {
        this.$apollo.addSmartQuery(
          profileType,
          this.createQuery({
            profileType,
            query,
            variables: {
              fullPath: this.projectFullPath,
              first: this.$options.profilesPerPage,
            },
          }),
        );
      });
    },
    getProfiles(profileType) {
      return this[profileType].profiles || [];
    },
    hasMoreProfiles(profileType) {
      return this[profileType].pageInfo?.hasNextPage;
    },
    isLoadingProfiles(profileType) {
      return this.$apollo.queries[profileType].loading;
    },
    createQuery({ profileType, query, variables }) {
      return {
        query,
        variables,
        update({ project }) {
          const profileEdges = project?.[profileType]?.edges ?? [];
          const profiles = profileEdges.map(({ node }) => node);
          const pageInfo = project?.[profileType].pageInfo;

          return {
            profiles,
            pageInfo,
          };
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
    fetchMoreProfiles(profileType) {
      const {
        $apollo,
        $options: { i18n },
      } = this;
      const { pageInfo } = this[profileType];

      this.resetErrors();

      $apollo.queries[profileType]
        .fetchMore({
          variables: { after: pageInfo.endCursor },
          updateQuery: cacheUtils.appendToPreviousResult(profileType),
        })
        .catch(error => {
          this.handleError({ exception: error, message: i18n.errorMessages.fetchNetworkError });
        });
    },
    deleteProfile(profileType, profileId) {
      const {
        projectFullPath,
        handleError,
        $options,
        $apollo: {
          queries: {
            [profileType]: { options: queryOptions },
          },
        },
      } = this;

      const { deleteMutation } = $options.configs.find(
        config => config.profileType === profileType,
      );

      this.resetErrors();

      this.$apollo
        .mutate({
          mutation: deleteMutation,
          variables: {
            projectFullPath,
            profileId,
          },
          update(store, { data = {} }) {
            const errors = data[`${profileType}Delete`]?.errors ?? [];

            if (errors.length === 0) {
              cacheUtils.removeProfile({
                profileId,
                profileType,
                store,
                queryBody: {
                  query: queryOptions.query,
                  variables: queryOptions.variables,
                },
              });
            } else {
              handleError({
                message: $options.i18n.errorMessages.deletionBackendError,
                details: errors,
              });
            }
          },
          optimisticResponse: cacheUtils.dastProfilesDeleteResponse(profileType),
        })
        .catch(error => {
          this.handleError({
            exception: error,
            message: $options.i18n.errorMessages.deletionNetworkError,
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
      <gl-tab v-for="{ profileType, i18n } in getEnabledProfileConfigs()" :key="profileType">
        <template #title>
          <span>{{ i18n.title }}</span>
        </template>

        <profiles-list
          :error-message="errorMessage"
          :error-details="errorDetails"
          :has-more-profiles-to-load="hasMoreProfiles(profileType)"
          :is-loading="isLoadingProfiles(profileType)"
          :profiles-per-page="$options.profilesPerPage"
          :profiles="getProfiles(profileType)"
          :fields="profileOptions.fields"
          @loadMoreProfiles="fetchMoreProfiles(profileType)"
          @deleteProfile="deleteProfile(profileType, $event)"
        />
      </gl-tab>
    </gl-tabs>
  </section>
</template>
