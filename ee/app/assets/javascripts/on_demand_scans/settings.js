import dastScannerProfilesQuery from 'ee/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesQuery from 'ee/dast_profiles/graphql/dast_site_profiles.query.graphql';
import { s__ } from '~/locale';

export const ERROR_RUN_SCAN = 'ERROR_RUN_SCAN';
export const ERROR_FETCH_SCANNER_PROFILES = 'ERROR_FETCH_SCANNER_PROFILES';
export const ERROR_FETCH_SITE_PROFILES = 'ERROR_FETCH_SITE_PROFILES';

export const ERROR_MESSAGES = {
  [ERROR_RUN_SCAN]: s__('OnDemandScans|Could not run the scan. Please try again.'),
  [ERROR_FETCH_SCANNER_PROFILES]: s__(
    'OnDemandScans|Could not fetch scanner profiles. Please refresh the page, or try again later.',
  ),
  [ERROR_FETCH_SITE_PROFILES]: s__(
    'OnDemandScans|Could not fetch site profiles. Please refresh the page, or try again later.',
  ),
};

export const getProfilesSettings = ({
  scannerProfilesLibraryPath,
  newScannerProfilePath,
  siteProfilesLibraryPath,
  newSiteProfilePath,
}) => ({
  scannerProfiles: {
    field: 'dastScannerProfileId',
    fetchQuery: dastScannerProfilesQuery,
    fetchError: ERROR_FETCH_SCANNER_PROFILES,
    queryKind: 'scannerProfiles',
    libraryPath: scannerProfilesLibraryPath,
    newProfilePath: newScannerProfilePath,
    selectedProfileDropdownLabel: profile => profile.profileName,
    i18n: {
      title: s__('OnDemandScans|Scanner profile'),
      formGroupLabel: s__('OnDemandScans|Use existing scanner profile'),
      noProfilesText: s__(
        'OnDemandScans|No profile yet. In order to create a new scan, you need to have at least one completed scanner profile.',
      ),
      newProfileLabel: s__('OnDemandScans|Create a new scanner profile'),
    },
    summary: [
      [
        {
          label: s__('DastProfiles|Scan mode'),
          valueGetter: () => s__('DastProfiles|Passive'),
        },
      ],
      [
        {
          label: s__('DastProfiles|Spider timeout'),
          valueGetter: profile => profile.spiderTimeout,
        },
        {
          label: s__('DastProfiles|Target timeout'),
          valueGetter: profile => profile.targetTimeout,
        },
      ],
    ],
  },
  siteProfiles: {
    field: 'dastSiteProfileId',
    fetchQuery: dastSiteProfilesQuery,
    fetchError: ERROR_FETCH_SITE_PROFILES,
    queryKind: 'siteProfiles',
    libraryPath: siteProfilesLibraryPath,
    newProfilePath: newSiteProfilePath,
    selectedProfileDropdownLabel: profile => `${profile.profileName}: ${profile.targetUrl}`,
    i18n: {
      title: s__('OnDemandScans|Site profile'),
      formGroupLabel: s__('OnDemandScans|Use existing site profile'),
      noProfilesText: s__(
        'OnDemandScans|No profile yet. In order to create a new scan, you need to have at least one completed site profile.',
      ),
      newProfileLabel: s__('OnDemandScans|Create a new site profile'),
    },
    summary: [
      [
        {
          label: s__('DastProfiles|Target URL'),
          valueGetter: profile => profile.targetUrl,
        },
      ],
    ],
  },
});
