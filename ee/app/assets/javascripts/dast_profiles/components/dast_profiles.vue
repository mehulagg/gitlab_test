<script>
import * as Sentry from '@sentry/browser';
import { GlButton, GlTab, GlTabs } from '@gitlab/ui';
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ProfilesList from './dast_profiles_list.vue';
import * as cacheUtils from '../graphql/cache_utils';
import profileConfigs from '../constants/profile_configs';

const getEnabledProfileConfigs = glFeatures =>
  Object.fromEntries(
    Object.entries(profileConfigs).filter(([, { isDisabled }]) => {
      // a config has to be explicitly disabled
      if (typeof isDisabled !== 'function') {
        return true;
      }

      return !isDisabled(glFeatures);
    }),
  );

export default {
  components: {
    GlButton,
    GlTab,
    GlTabs,
    ProfilesList,
  },
  mixins: [glFeatureFlagsMixin()],
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
      profileTypes: {},
      errorMessage: '',
      errorDetails: [],
    };
  },
  created() {
    this.profileConfigs = getEnabledProfileConfigs(this.glFeatures);
    this.addSmartQueriesForEnabledProfileTypes();
  },
  methods: {
    addSmartQueriesForEnabledProfileTypes() {
      Object.values(this.profileConfigs).forEach(({ profileType, graphQL: { query } }) => {
        this.makeProfileTypeReactive(profileType);
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
    makeProfileTypeReactive(profileType) {
      this.$set(this.profileTypes, profileType, {
        profiles: [],
        pageInfo: {},
      });
    },
    getProfiles(profileType) {
      return this.profileTypes[profileType]?.profiles || [];
    },
    hasMoreProfiles(profileType) {
      return this.profileTypes[profileType]?.pageInfo?.hasNextPage;
    },
    isLoadingProfiles(profileType) {
      return this.$apollo.queries[profileType].loading;
    },
    createQuery({ profileType, query, variables }) {
      return {
        query,
        variables,
        manual: true,
        result({ data, error }) {
          if (!error) {
            const { project } = data;
            const profileEdges = project?.[profileType]?.edges ?? [];
            const profiles = profileEdges.map(({ node }) => node);
            const pageInfo = project?.[profileType].pageInfo;

            this.profileTypes[profileType] = {
              profiles,
              pageInfo,
            };
          }
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
      const { pageInfo } = this.profileTypes[profileType];

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
        $options: { i18n },
        profileConfigs: {
          [profileType]: {
            graphQL: { deletion },
          },
        },
        $apollo: {
          queries: {
            [profileType]: { options: queryOptions },
          },
        },
      } = this;

      this.resetErrors();

      this.$apollo
        .mutate({
          mutation: deletion.mutation,
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
                message: i18n.errorMessages.deletionBackendError,
                details: errors,
              });
            }
          },
          optimisticResponse: deletion.optimisticResponse,
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
      <gl-tab v-for="(data, profileType) in profileTypes" :key="profileType">
        <template #title>
          <span>{{ profileConfigs[profileType].i18n.title }}</span>
        </template>

        <profiles-list
          :error-message="errorMessage"
          :error-details="errorDetails"
          :has-more-profiles-to-load="hasMoreProfiles(profileType)"
          :is-loading="isLoadingProfiles(profileType)"
          :profiles-per-page="$options.profilesPerPage"
          :profiles="data.profiles"
          :fields="profileConfigs[profileType].fields"
          @loadMoreProfiles="fetchMoreProfiles(profileType)"
          @deleteProfile="deleteProfile(profileType, $event)"
        />
      </gl-tab>
    </gl-tabs>
  </section>
</template>
