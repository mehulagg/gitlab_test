import { s__ } from '~/locale';

const TRANSLATION_IS_LOADING = s__('ciReport|%{reportType} is loading');
const TRANSLATION_HAS_ERROR = s__('ciReport|%{reportType}: Loading resulted in an error');

const SAST = s__('ciReport|SAST');
const DAST = s__('ciReport|DAST');
const CONTAINER_SCANNING = s__('ciReport|Container scanning');
const DEPENDENCY_SCANNING = s__('ciReport|Dependency scanning');

export default {
  SAST,
  DAST,
  CONTAINER_SCANNING,
  DEPENDENCY_SCANNING,
  TRANSLATION_IS_LOADING,
  TRANSLATION_HAS_ERROR,
};
