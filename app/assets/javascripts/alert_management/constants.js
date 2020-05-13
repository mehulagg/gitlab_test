import { s__ } from '~/locale';

export const ALERTS_SEVERITY_LABELS = {
  CRITICAL: s__('AlertManagement|Critical'),
  HIGH: s__('AlertManagement|High'),
  MEDIUM: s__('AlertManagement|Medium'),
  LOW: s__('AlertManagement|Low'),
  INFO: s__('AlertManagement|Info'),
  UNKNOWN: s__('AlertManagement|Unknown'),
};

export const ALERT_STATUS_LABELS = {
  OPEN: s__('AlertManagement|Open'),
  TRIGGERED: s__('AlertManagement|Triggered'),
  ACKNOWLEDGED: s__('AlertManagement|Acknowledged'),
  RESOLVED: s__('AlertManagement|Resolved'),
  ALL: s__('AlertManagement|All alerts'),
};

export const CLICKABLE_STATUSES = ['TRIGGERED', 'ACKNOWLEDGED', 'RESOLVED'];

export const ALERTS_STATUS = {
  OPEN: 'open',
  TRIGGERED: 'triggered',
  ACKNOWLEDGED: 'acknowledged',
  RESOLVED: 'resolved',
  ALL: 'all',
};

export const ALERTS_STATUS_TABS = Object.keys(ALERT_STATUS_LABELS).map(key => ({
  title: ALERT_STATUS_LABELS[key],
  status: ALERTS_STATUS[key],
}));
