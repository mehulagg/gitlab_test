import { __ } from '~/locale';

export const PackageType = {
  CONAN: 'conan',
  MAVEN: 'maven',
  NPM: 'npm',
  NUGET: 'nuget',
  PYPI: 'pypi',
  COMPOSER: 'composer',
};

export const TrackingActions = {
  DELETE_PACKAGE: 'delete_package',
  REQUEST_DELETE_PACKAGE: 'request_delete_package',
  CANCEL_DELETE_PACKAGE: 'cancel_delete_package',
  PULL_PACKAGE: 'pull_package',
  COMING_SOON_REQUESTED: 'activate_coming_soon_requested',
  COMING_SOON_LIST: 'click_coming_soon_issue_link',
  COMING_SOON_HELP: 'click_coming_soon_documentation_link',
};

export const TrackingCategories = {
  [PackageType.MAVEN]: 'MavenPackages',
  [PackageType.NPM]: 'NpmPackages',
  [PackageType.CONAN]: 'ConanPackages',
};

export const SHOW_DELETE_SUCCESS_ALERT = 'showSuccessDeleteAlert';
export const DELETE_PACKAGE_ERROR_MESSAGE = __('Something went wrong while deleting the package.');
