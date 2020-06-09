<script>
import { __ } from '~/locale';
import { ERROR_MESSAGES } from './constants';
import { GlIcon, GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import MrCollapsibleExtension from '../mr_collapsible_extension.vue';
import Poll from '~/lib/utils/poll';

export default {
  name: 'MRWidgetTerraformPlan',
  components: {
    GlIcon,
    GlLink,
    GlLoadingIcon,
    GlSprintf,
    MrCollapsibleExtension
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      loading: true,
      plans: {},
    };
  },
  computed: {
    addNum() {
      return Number(this.plan.create);
    },
    changeNum() {
      return Number(this.plan.update);
    },
    deleteNum() {
      return Number(this.plan.delete);
    },
    errorType() {
      return ERROR_MESSAGES[this.plan.tf_report_error] || ERROR_MESSAGES.default
    },
    logUrl() {
      return this.plan.job_path;
    },
    plan() {
      return this.plans['tfplan.json'] || {};
    },
    validPlanValues() {
      return this.addNum + this.changeNum + this.deleteNum >= 0;
    },
  },
  created() {
    this.fetchPlans();
  },
  methods: {
    fetchPlans() {
      this.loading = true;

      const poll = new Poll({
        resource: {
          fetchPlans: () => axios.get(this.endpoint),
        },
        data: this.endpoint,
        method: 'fetchPlans',
        successCallback: ({ data }) => {
          this.plans = data;

          if (Object.keys(this.plan).length) {
            this.loading = false;
            poll.stop();
          }
        },
        errorCallback: () => {
          this.plans = { 'tf_report_error': 'api_error' };
          this.loading = false;
        },
      });

      poll.makeRequest();
    },
  },
};
</script>

<template>
  <section class="mr-widget-section">
    <div class="mr-widget-body media d-flex flex-row">
      <span class="append-right-default align-self-start align-self-lg-center">
        <gl-icon name="status_warning" :size="24" />
      </span>

      <div class="d-flex flex-fill flex-column flex-md-row">
        <div class="terraform-mr-plan-text normal d-flex flex-column flex-lg-row">
          <p class="m-0 pr-1">{{ __('A Terraform report was generated in your pipelines.') }}</p>

          <gl-loading-icon v-if="loading" size="md" />
        </div>

        <div class="terraform-mr-plan-actions">
          <gl-link
            v-if="logUrl"
            :href="logUrl"
            target="_blank"
            data-track-event="click_terraform_mr_plan_button"
            data-track-label="mr_widget_terraform_mr_plan_button"
            data-track-property="terraform_mr_plan_button"
            class="btn btn-sm js-terraform-report-link"
            rel="noopener"
          >
            {{ __('View full log') }}
            <gl-icon name="external-link" />
          </gl-link>
        </div>
      </div>
    </div>

    <div
      class="mr-widget-extension gl-display-flex gl-px-6 gl-py-3"
      v-if="validPlanValues"
    >
      <p class="gl-m-0 gl-ml-7">
        <gl-sprintf
          :message="
            __(
              'Reported resource changes: %{addNum} to add, %{changeNum} to change, %{deleteNum} to delete',
            )
          "
        >
          <template #addNum>
            <strong>{{ addNum }}</strong>
          </template>

          <template #changeNum>
            <strong>{{ changeNum }}</strong>
          </template>

          <template #deleteNum>
            <strong>{{ deleteNum }}</strong>
          </template>
        </gl-sprintf>
      </p>
    </div>

    <mr-collapsible-extension
      :title="errorType.shortMessage"
      v-else
    >
      <div class="gl-mx-6 gl-px-7">
        <p class="gl-m-3">
          <strong>{{ errorType.longMessageHeader }}</strong>
        </p>

        <p class="gl-m-3">{{ errorType.longMessage }}</p>

        <p class="gl-m-3">
          <gl-link
            href="https://docs.gitlab.com/ee/user/infrastructure/#output-terraform-plan-information-into-a-merge-request"
            target="_blank"
            rel="noopener"
          >
            Go to documentation
          </gl-link>for help on setting up your Terraform report.
        </p>
      </div>
    </mr-collapsible-extension>
  </section>
</template>
