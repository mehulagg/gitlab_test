import Vue from 'vue';
import Vuex from 'vuex';

import modalModule from '~/vuex_shared/modules/modal';
import projectSettingsModule from 'ee/approvals/stores/modules/project_settings';

import mediator from './plugins/mediator';

import listModule from './modules/list';
import { licenseManagementModule } from 'ee/vue_shared/license_compliance/store/index';
import { LICENSE_LIST } from './constants';
import { LICENSE_MANAGEMENT } from 'ee/vue_shared/license_compliance/store/constants';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    state: {
      settings: {
        canEdit: true,
        eligibleApproversDocsPath:
          '/help/user/project/merge_requests/merge_request_approvals#eligible-approvers',
        prefix: 'project-settings',
        projectId: '43',
        projectPath: '/api/v4/projects/43',
        rulesPath: '/api/v4/projects/43/approval_settings/rules',
        securityApprovalsHelpPagePath:
          '/help/user/application_security/index.html#security-approvals-in-merge-requests-ultimate',
        settingsPath: '/api/v4/projects/43/approval_settings',
      },
    },
    modules: {
      [LICENSE_LIST]: listModule(),
      [LICENSE_MANAGEMENT]: licenseManagementModule(),
      approvals: projectSettingsModule(),
      createModal: modalModule(),
    },
    plugins: [mediator],
  });
