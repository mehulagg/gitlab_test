import { __, s__ } from '~/locale';

import UserToken from './tokens/user_token.vue';
import GroupToken from './tokens/group_token.vue';
import ProjectToken from './tokens/project_token.vue';

const apiConfig = {
  all: {
    path: '/api/v4/audit_events',
  },
  users: {
    path: '/autocomplete/users.json',
    defaultParams: {
      active: true,
      current_user: true,
    },
  },
  projects: {
    path: '/api/v4/projects.json',
    defaultParams: {
      per_page: 20,
      simple: true,
      membership: false,
      order_by: 'last_activity_at',
    },
  },
  groups: {
    path: '/api/v4/groups.json',
    defaultParams: {
      per_page: 20,
      page: 1,
      all_available: true,
    },
  },
};

export const FILTER_TOKENS = [
  {
    type: 'user_id',
    icon: 'user',
    hint: s__('AuditLogs|User Events'),
    title: s__('AuditLogs|User Events'),
    token: UserToken,
    config: apiConfig.users,
    hidden: false,
  },
  {
    type: 'group_id',
    icon: 'group',
    hint: s__('AuditLogs|Group Events'),
    title: s__('AuditLogs|Group Events'),
    token: GroupToken,
    config: apiConfig.groups,
  },
  {
    type: 'project_id',
    icon: 'tanuki',
    hint: s__('AuditLogs|Project Events'),
    title: s__('AuditLogs|Project Events'),
    token: ProjectToken,
    config: apiConfig.projects,
  },
];

export const SORT_FIELDS = [
  { key: 'created_desc', text: __('Last created') },
  { key: 'created_asc', text: __('Oldest created') },
];

export const SORT_ORDER = {
  ascending: 'created_asc',
  descending: 'created_desc',
};
