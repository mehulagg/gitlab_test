import { __, s__ } from '~/locale';

export const SORT_FIELDS = {
  name: s__('Dependencies|Component name'),
  type: s__('Dependencies|Packager'),
};

export const SORT_ORDER = {
  ascending: 'asc',
  descending: 'desc',
};

export const REPORT_STATUS = {
  ok: '',
  jobNotSetUp: 'job_not_set_up',
  jobFailed: 'job_failed',
  incomplete: 'no_dependency_files',
};

export const FETCH_ERROR_MESSAGE = __(
  'Error fetching the Dependency List. Please check your network connection and try again.',
);
