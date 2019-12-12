import { n__, __, sprintf } from '~/locale';
import { parseLicenseReportMetrics } from './utils';
import { LICENSE_APPROVAL_STATUS } from '../constants';

export const isLoading = state => state.isLoadingManagedLicenses || state.isLoadingLicenseReport;

export const licenseReport = state =>
  gon.features && gon.features.parsedLicenseReport
    ? state.newLicenses
    : parseLicenseReportMetrics(state.headReport, state.baseReport, state.managedLicenses);

export const licenseSummaryText = (state, getters) => {
  const hasReportItems = getters.licenseReport && getters.licenseReport.length;
  const baseReportHasLicenses =
    state.existingLicenses.length ||
    (state.baseReport && state.baseReport.licenses && state.baseReport.licenses.length);

  if (getters.isLoading) {
    return sprintf(__('Loading %{reportName} report'), {
      reportName: __('License Compliance'),
    });
  }

  if (state.loadLicenseReportError) {
    return sprintf(__('Failed to load %{reportName} report'), {
      reportName: __('License Compliance'),
    });
  }

  if (hasReportItems) {
    const licenseReportLength = getters.licenseReport.length;

    if (!baseReportHasLicenses) {
      return getters.reportContainsBlacklistedLicense
        ? n__(
            'License Compliance detected %d license for the source branch only; approval required',
            'License Compliance detected %d licenses for the source branch only; approval required',
            licenseReportLength,
          )
        : n__(
            'License Compliance detected %d license for the source branch only',
            'License Compliance detected %d licenses for the source branch only',
            licenseReportLength,
          );
    }

    return getters.reportContainsBlacklistedLicense
      ? n__(
          'License Compliance detected %d new license; approval required',
          'License Compliance detected %d new licenses; approval required',
          licenseReportLength,
        )
      : n__(
          'License Compliance detected %d new license',
          'License Compliance detected %d new licenses',
          licenseReportLength,
        );
  }

  if (!baseReportHasLicenses) {
    return __('License Compliance detected no licenses for the source branch only');
  }

  return __('License Compliance detected no new licenses');
};

export const reportContainsBlacklistedLicense = (_state, getters) =>
  (getters.licenseReport || []).some(
    license => license.approvalStatus === LICENSE_APPROVAL_STATUS.BLACKLISTED,
  );

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
