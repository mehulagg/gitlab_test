<script>
import { GlButton, GlFormCheckbox, GlIcon, GlLink } from '@gitlab/ui';
import CILintResults from './ci_lint_results.vue';
import lintCIMutation from '../graphql/mutations/lint_ci.mutation.graphql';

export default {
  components: {
    GlButton,
    GlFormCheckbox,
    GlIcon,
    GlLink,
    'ci-lint-results': CILintResults,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    helpPagePath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      valid: false,
      errors: null,
      warnings: null,
      jobs: [],
      dryRun: false,
      showingResults: false,
    };
  },
  methods: {
    async lint() {
      const config = `
        stages:
          - build
          - test
          - deploy

        job_1:
          stage: build
          script: echo 'Building'
          only:
            - web
            - chat
            - pushes
          allow_failure: true

        multi_project_job:
          stage: test
          trigger: root/ci-project

        microservice_a:
          stage: test
          trigger:
            include: config/microservice_a.yml
        job_2:
          script: echo 'job'
          only:
            - branches@gitlab-org/gitlab
          except:
            - master@gitlab-org/gitlab
            - /^release/.*$/@gitlab-org/gitlab
      `;

      const {
        data: {
          lintCI: { valid, errors, warnings, jobs },
        },
      } = await this.$apollo.mutate({
        mutation: lintCIMutation,
        variables: { endpoint: this.endpoint, content: config, dry: this.dryRun },
      });

      this.showingResults = true;
      this.valid = valid;
      this.errors = errors;
      this.warnings = warnings;
      this.jobs = jobs;
    },
  },
};
</script>

<template>
  <div class="row">
    <div class="col-sm-12">
      <!-- Vue editor lite component goes here #232503 -->
    </div>

    <div class="col-sm-12 gl-display-flex gl-justify-content-space-between">
      <div class="gl-display-flex gl-align-items-center">
        <gl-button class="gl-mr-4" category="primary" variant="success" @click="lint">{{
          __('Validate')
        }}</gl-button>
        <gl-form-checkbox v-model="dryRun"
          >{{ __('Simulate a pipeline created for the default branch') }}
          <gl-link :href="helpPagePath" target="_blank"
            ><gl-icon class="gl-text-blue-600" name="question-o"/></gl-link
        ></gl-form-checkbox>
      </div>
      <gl-button>{{ __('Clear') }}</gl-button>
    </div>

    <ci-lint-results
      v-if="showingResults"
      :valid="valid"
      :jobs="jobs"
      :errors="errors"
      :warnings="warnings"
      :dry-run="dryRun"
    />
  </div>
</template>
