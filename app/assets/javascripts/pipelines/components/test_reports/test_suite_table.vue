<script>
import { mapGetters } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';
import { __ } from '~/locale';
import { GlTooltipDirective } from '@gitlab/ui';
import SmartVirtualList from '~/vue_shared/components/smart_virtual_list.vue';

export default {
  name: 'TestsSuiteTable',
  components: {
    Icon,
    SmartVirtualList,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    heading: {
      type: String,
      required: false,
      default: __('Tests'),
    },
  },
  computed: {
    ...mapGetters(['getSuiteTests']),
    hasSuites() {
      return this.getSuiteTests.length > 0;
    },
  },
  maxShownRows: 30,
  typicalRowHeight: 75,
};
</script>

<template>
  <div>
    <div class="row gl-mt-3">
      <div class="col-12">
        <h4>{{ heading }}</h4>
      </div>
    </div>

    <div v-if="hasSuites" class="test-reports-table gl-mb-3 js-test-cases-table">
      <div
        role="row"
        class="gl-responsive-table-row table-row-header gl-font-weight-bold gl-fill-gray-700"
      >
        <div role="rowheader" class="table-section section-20">
          {{ __('Suite') }}
        </div>
        <div role="rowheader" class="table-section section-20">
          {{ __('Name') }}
        </div>
        <div role="rowheader" class="table-section section-10 gl-text-center">
          {{ __('Status') }}
        </div>
        <div role="rowheader" class="table-section gl-flex-grow-1">
          {{ __('Trace'), }}
        </div>
        <div role="rowheader" class="table-section section-10 gl-text-right">
          {{ __('Duration') }}
        </div>
      </div>

      <smart-virtual-list
        :length="getSuiteTests.length"
        :remain="$options.maxShownRows"
        :size="$options.typicalRowHeight"
      >
        <div
          v-for="(testCase, index) in getSuiteTests"
          :key="index"
          class="gl-responsive-table-row gl-rounded-base align-items-md-start gl-xs-mt-6 js-case-row"
        >
          <div class="table-section section-20 section-wrap">
            <div role="rowheader" class="table-mobile-header">{{ __('Suite') }}</div>
            <div class="table-mobile-content gl-md-pr-2 gl-overflow-wrap-break">
              {{ testCase.classname }}
            </div>
          </div>

          <div class="table-section section-20 section-wrap">
            <div role="rowheader" class="table-mobile-header">{{ __('Name') }}</div>
            <div class="table-mobile-content gl-md-pr-2 gl-overflow-wrap-break">
              {{ testCase.name }}
            </div>
          </div>

          <div class="table-section section-10 section-wrap">
            <div role="rowheader" class="table-mobile-header">{{ __('Status') }}</div>
            <div class="table-mobile-content gl-text-center">
              <div
                class="add-border ci-status-icon gl-display-flex gl-align-items-center gl-justify-content-end gl-justify-content-md-center"
                :class="`ci-status-icon-${testCase.status}`"
              >
                <icon :size="24" :name="testCase.icon" />
              </div>
            </div>
          </div>

          <div class="table-section gl-flex-grow-1">
            <div role="rowheader" class="table-mobile-header">{{ __('Trace'), }}</div>
            <div class="table-mobile-content">
              <pre
                v-if="testCase.system_output"
                class="build-trace build-trace-rounded gl-text-left"
              ><code class="bash gl-p-0">{{testCase.system_output}}</code></pre>
            </div>
          </div>

          <div class="table-section section-10 section-wrap">
            <div role="rowheader" class="table-mobile-header">
              {{ __('Duration') }}
            </div>
            <div class="table-mobile-content text-right gl-sm-pr-2">
              {{ testCase.formattedTime }}
            </div>
          </div>
        </div>
      </smart-virtual-list>
    </div>

    <div v-else>
      <p class="js-no-test-cases">{{ s__('TestReports|There are no test cases to display.') }}</p>
    </div>
  </div>
</template>
