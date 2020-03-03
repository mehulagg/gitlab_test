<script>
import { GlFilteredSearch } from '@gitlab/ui';
import { objectToQuery, visitUrl, mergeUrlParams } from '~/lib/utils/url_utility';

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

export default {
  name: 'AuditLogFilter',
  components: {
    UserToken,
    GroupToken,
    ProjectToken,
    GlFilteredSearch,
  },
  data() {
    return {
      searchTerms: [],
    };
  },
  methods: {
    parseSearchTerms(terms) {
      return terms.filter(({ value }) => !!value).map(({ value, type }) => ({ [type]: value }));
    },
    allowedTokens(tokens) {
      return tokens;
      // return tokens.filter(({ type }) =>
      //   !this.searchTerms.find(({type: searched, value}) =>
      //     type === searched && value !== ''
      //   )
      // )
    },
    parseFormData(terms) {
      // ?sort=created_desc&entity_type=User&entity_id=1&created_after=2020-03-02&created_before=2020-03-03
      return this.parseSearchTerms(terms).map(e => {
        if ('user_id' in e) {
          return { entity_id: e.user_id, entity_type: 'User' };
        }

        if ('group_id' in e) {
          return { entity_id: e.group_id, entity_type: 'Group' };
        }

        if ('project_id' in e) {
          return { entity_id: e.project_id, entity_type: 'Project' };
        }
      });
    },
    handleSubmit(formData) {
      console.log(formData);
      const data = this.parseFormData(formData);
      console.log(data);
      const query = data.map(e => objectToQuery(e).toString()).join('&');
      const merged = Object.assign(...data);

      //visitUrl(mergeUrlParams(merged, window.location.href));
    },
  },
  filterTokens: [
    {
      type: 'user_id',
      icon: 'user',
      hint: 'User Events',
      title: 'User Events',
      token: UserToken,
      config: apiConfig.users,
      hidden: false,
    },
    {
      type: 'group_id',
      icon: 'group',
      hint: 'Group Events',
      title: 'Group Events',
      token: GroupToken,
      config: apiConfig.groups,
    },
    {
      type: 'project_id',
      icon: 'tanuki',
      hint: 'Project Events',
      title: 'Project Events',
      token: ProjectToken,
      config: apiConfig.projects,
    },
  ],
};
</script>

<template>
  <gl-filtered-search
    @submit="handleSubmit"
    :available-tokens="allowedTokens($options.filterTokens)"
    v-model="searchTerms"
  />
</template>
