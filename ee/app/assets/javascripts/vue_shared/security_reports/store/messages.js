import { __, sprintf } from '~/locale';

const TRANSLATION_IS_LOADING = __('%{reportType} is loading');
const TRANSLATION_HAS_ERROR = __('%{reportType}: Loading resulted in an error');

const SAST = __('SAST');
const DAST = __('DAST');
const CONTAINER_SCANNING = __('Container scanning');
const DEPENDENCY_SCANNING = __('Dependency scanning');

export default {
  SAST,
  DAST,
  CONTAINER_SCANNING,
  DEPENDENCY_SCANNING,
  TRANSLATION_IS_LOADING,
  TRANSLATION_HAS_ERROR,
  SAST_IS_LOADING: sprintf(TRANSLATION_IS_LOADING, { reportType: SAST }),
  SAST_HAS_ERROR: sprintf(TRANSLATION_HAS_ERROR, { reportType: SAST }),
  DAST_IS_LOADING: sprintf(TRANSLATION_IS_LOADING, { reportType: DAST }),
  DAST_HAS_ERROR: sprintf(TRANSLATION_HAS_ERROR, { reportType: DAST }),
  CONTAINER_SCANNING_IS_LOADING: sprintf(TRANSLATION_IS_LOADING, {
    reportType: CONTAINER_SCANNING,
  }),
  CONTAINER_SCANNING_HAS_ERROR: sprintf(TRANSLATION_HAS_ERROR, { reportType: CONTAINER_SCANNING }),
  DEPENDENCY_SCANNING_IS_LOADING: sprintf(TRANSLATION_IS_LOADING, {
    reportType: DEPENDENCY_SCANNING,
  }),
  DEPENDENCY_SCANNING_HAS_ERROR: sprintf(TRANSLATION_HAS_ERROR, {
    reportType: DEPENDENCY_SCANNING,
  }),
};
