import { getProfilesSettings } from 'ee/on_demand_scans/settings';

describe('On-demand Scans Settings', () => {
  it('builds settings object properly', () => {
    expect(
      getProfilesSettings({
        scannerProfilesLibraryPath: '/scanner/profiles/library/path',
        newScannerProfilePath: '/new/scanner/profile/path',
        siteProfilesLibraryPath: '/site/profiles/library/path',
        newSiteProfilePath: '/new/site/profile/path',
      }),
    ).toMatchSnapshot();
  });
});
