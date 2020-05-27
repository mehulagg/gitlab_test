import awsSvg from '@gitlab/svgs/dist/illustrations/logos/amazon_eks.svg';
import defaultKubernetesSvg from '@gitlab/svgs/dist/illustrations/logos/kubernetes.svg';
import gcpSvg from '@gitlab/svgs/dist/illustrations/logos/google_gke.svg';
import { __ } from '~/locale';

export const CLUSTER_TYPES = {
  project_type: __('Project'),
  group_type: __('Group'),
  instance_type: __('Instance'),
};

export const MAX_REQUESTS = 3;

export const PROVIDER_TYPES = {
  aws: {
    icon: `data:image/svg+xml;base64,${btoa(awsSvg)}`,
    iconText: __('Cluster|Amazon EKS'),
  },
  default: {
    icon: `data:image/svg+xml;base64,${btoa(defaultKubernetesSvg)}`,
    iconText: __('Cluster|Kubernetes Cluster'),
  },
  gcp: {
    icon: `data:image/svg+xml;base64,${btoa(gcpSvg)}`,
    iconText: __('Cluster|Google GKE'),
  },
};

export const STATUSES = {
  default: { className: 'bg-white', title: __('Unknown') },
  disabled: { className: 'disabled', title: __('Disabled') },
  created: { className: 'bg-success', title: __('Connected') },
  unreachable: { className: 'bg-danger', title: __('Unreachable') },
  authentication_failure: { className: 'bg-warning', title: __('Authentication Failure') },
  deleting: { title: __('Deleting') },
};
