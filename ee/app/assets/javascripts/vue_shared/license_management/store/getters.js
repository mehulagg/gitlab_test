import { n__, s__, sprintf } from '~/locale';
import { parseLicenseReportMetrics } from './utils';

export default {
  isLoading: state => state.isLoadingManagedLicenses || state.isLoadingLicenseReport,

  licenseReport: state =>
    parseLicenseReportMetrics(state.headReport, state.baseReport, state.managedLicenses),

  licenseSummaryText: (state, getters) => {
    const hasReportItems = getters.licenseReport && getters.licenseReport.length;
    const baseReportHasLicenses =
      state.baseReport && state.baseReport.licenses && state.baseReport.licenses.length;

    if (getters.isLoading) {
      return sprintf(s__('ciReport|Loading %{reportName} report'), {
        reportName: s__('license management'),
      });
    }

    if (state.loadLicenseReportError) {
      return sprintf(s__('ciReport|Failed to load %{reportName} report'), {
        reportName: s__('license management'),
      });
    }

    if (hasReportItems) {
      if (!baseReportHasLicenses) {
        return n__(
          'ciReport|License management detected %d license for the source branch only',
          'ciReport|License management detected %d licenses for the source branch only',
          getters.licenseReport.length,
        );
      }

      return n__(
        'ciReport|License management detected %d new license',
        'ciReport|License management detected %d new licenses',
        getters.licenseReport.length,
      );
    }

    if (!baseReportHasLicenses) {
      return s__('ciReport|License management detected no licenses for the source branch only');
    }

    return s__('ciReport|License management detected no new licenses');
  },
};
