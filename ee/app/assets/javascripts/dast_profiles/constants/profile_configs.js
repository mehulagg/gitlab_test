import { s__ } from '~/locale';
import dastSiteProfilesQuery from '../graphql/dast_site_profiles.query.graphql';
import dastScannerProfilesQuery from '../graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesDelete from '../graphql/dast_site_profiles_delete.mutation.graphql';
import dastScannerProfilesDelete from '../graphql/dast_scanner_profiles_delete.mutation.graphql';

export default {
  siteProfiles: {
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
  scannerProfiles: {
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
};
