import { __ } from '~/locale';

export const CLUSTER_TYPES = {
  project_type: __('Project'),
  group_type: __('Group'),
  instance_type: __('Instance'),
};

// https://github.com/kubernetes/kubernetes/blob/8fd414537b5143ab039cb910590237cabf4af783/pkg/api/resource/suffix.go#L108
// https://github.com/kubernetes/apimachinery/blob/1f207b29b4411fb6ecfd342ae73fa60a921a5046/pkg/api/resource/quantity.go#L30-L80
export const K8S_MEASUREMENTS = {
  n: { base: 10, exponent: -9, stringLength: 1 },
  u: { based: 10, exponent: -6, stringLength: 1 },
  m: { base: 10, exponent: -3, stringLength: 1 },
  base: { base: 10, exponent: 0, stringLength: 0 },
  k: { base: 10, exponent: 3, stringLength: 1 },
  M: { base: 10, exponent: 6, stringLength: 1 },
  G: { base: 10, exponent: 9, stringLength: 1 },
  T: { base: 10, exponent: 12, stringLength: 1 },
  P: { base: 10, exponent: 15, stringLength: 1 },
  E: { base: 10, exponent: 18, stringLength: 1 },
  Ki: { base: 2, exponent: 10, stringLength: 2 },
  Mi: { base: 2, exponent: 20, stringLength: 2 },
  Gi: { base: 2, exponent: 30, stringLength: 2 },
  Ti: { base: 2, exponent: 40, stringLength: 2 },
  Pi: { base: 2, exponent: 50, stringLength: 2 },
  Ei: { base: 2, exponent: 60, stringLength: 2 },
};

export const MAX_REQUESTS = 3;

export const STATUSES = {
  default: { className: 'bg-white', title: __('Unknown') },
  disabled: { className: 'disabled', title: __('Disabled') },
  created: { className: 'bg-success', title: __('Connected') },
  unreachable: { className: 'bg-danger', title: __('Unreachable') },
  authentication_failure: { className: 'bg-warning', title: __('Authentication Failure') },
  deleting: { title: __('Deleting') },
  creating: { title: __('Creating') },
};
