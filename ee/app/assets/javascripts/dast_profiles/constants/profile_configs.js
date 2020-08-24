import dastSiteProfilesQuery from 'ee/dast_profiles/graphql/dast_site_profiles.query.graphql';
import dastScannerProfilesQuery from 'ee/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesDelete from 'ee/dast_profiles/graphql/dast_site_profiles_delete.mutation.graphql';
import dastScannerProfilesDelete from 'ee/dast_profiles/graphql/dast_scanner_profiles_delete.mutation.graphql';
import { dastProfilesDeleteResponse } from 'ee/dast_profiles/graphql/cache_utils';
import { s__ } from '~/locale';

export default {
  siteProfiles: {
    profileType: 'siteProfiles',
    graphQL: {
      query: dastSiteProfilesQuery,
      deletion: {
        mutation: dastSiteProfilesDelete,
        optimisticResponse: dastProfilesDeleteResponse({
          mutationName: 'siteProfilesDelete',
          payloadTypeName: 'DastSiteProfileDeletePayload',
        }),
      },
    },
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
  scannerProfiles: {
    profileType: 'scannerProfiles',
    graphQL: {
      query: dastScannerProfilesQuery,
      deletion: {
        mutation: dastScannerProfilesDelete,
        optimisticResponse: dastProfilesDeleteResponse({
          mutationName: 'scannerProfilesDelete',
          payloadTypeName: 'DastScannerProfileDeletePayload',
        }),
      },
    },
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
};
