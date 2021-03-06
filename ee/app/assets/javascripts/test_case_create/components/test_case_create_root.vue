<script>
import { GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import createFlash from '~/flash';
import { redirectTo } from '~/lib/utils/url_utility';

import IssuableCreate from '~/issuable_create/components/issuable_create_root.vue';

import createTestCase from '../queries/create_test_case.mutation.graphql';

export default {
  components: {
    GlButton,
    IssuableCreate,
  },
  inject: [
    'projectFullPath',
    'projectTestCasesPath',
    'descriptionPreviewPath',
    'descriptionHelpPath',
    'labelsFetchPath',
    'labelsManagePath',
  ],
  data() {
    return {
      createTestCaseRequestActive: false,
    };
  },
  methods: {
    handleTestCaseSubmitClick({ issuableTitle, issuableDescription, selectedLabels }) {
      this.createTestCaseRequestActive = true;
      return this.$apollo
        .mutate({
          mutation: createTestCase,
          variables: {
            createTestCaseInput: {
              projectPath: this.projectFullPath,
              title: issuableTitle,
              description: issuableDescription,
              labelIds: selectedLabels.map(label => label.id),
            },
          },
        })
        .then(({ data = {} }) => {
          const errors = data.createTestCase?.errors;
          if (errors?.length) {
            throw new Error(`Error creating a test case. Error message: ${errors[0].message}`);
          }
          redirectTo(this.projectTestCasesPath);
        })
        .catch(error => {
          createFlash({
            message: s__('TestCases|Something went wrong while creating a test case.'),
            captureError: true,
            error,
          });
        })
        .finally(() => {
          this.createTestCaseRequestActive = false;
        });
    },
  },
};
</script>

<template>
  <issuable-create
    :description-preview-path="descriptionPreviewPath"
    :description-help-path="descriptionHelpPath"
    :labels-fetch-path="labelsFetchPath"
    :labels-manage-path="labelsManagePath"
  >
    <template #title>
      <h3 class="page-title">{{ s__('TestCases|New Test Case') }}</h3>
    </template>
    <template #actions="issuableMeta">
      <div class="gl-flex-grow-1">
        <gl-button
          data-testid="submit-test-case"
          category="primary"
          variant="success"
          :loading="createTestCaseRequestActive"
          :disabled="!issuableMeta.issuableTitle.length"
          @click="handleTestCaseSubmitClick(issuableMeta)"
          >{{ s__('TestCases|Submit test case') }}</gl-button
        >
      </div>
      <gl-button
        data-testid="cancel-test-case"
        :disabled="createTestCaseRequestActive"
        :href="projectTestCasesPath"
        >{{ __('Cancel') }}</gl-button
      >
    </template>
  </issuable-create>
</template>
