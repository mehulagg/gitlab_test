import { __ } from '~/locale';

export const FILTER_HEADER = __('Confidentiality');

export const FILTER_TEXT = __('Any Confidentiality');

export const FILTER_STATES = {
  ANY: {
    label: __('Any'),
    value: null,
  },
  CONFIDENTIAL: {
    label: __('Confidential'),
    value: 'yes',
  },
  NOT_CONFIDENTIAL: {
    label: __('Not confidential'),
    value: 'no',
  },
};
