<script>
import { GlAlert, GlButton, GlIcon, GlLink } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { cloneDeep } from 'lodash';
import { __, s__ } from '~/locale';
import { redirectTo } from '~/lib/utils/url_utility';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import AnalyzerConfiguration from './analyzer_configuration.vue';
import DynamicFields from './dynamic_fields.vue';
import ExpandableSection from './expandable_section.vue';
import configureSastMutation from '../graphql/configure_sast.mutation.graphql';
import {
  toSastCiConfigurationEntityInput,
  toSastCiConfigurationAnalyzerEntityInput,
} from './utils';

export default {
  components: {
    AnalyzerConfiguration,
    DynamicFields,
    ExpandableSection,
    GlAlert,
    GlButton,
    GlIcon,
    GlLink,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    createSastMergeRequestPath: {
      from: 'createSastMergeRequestPath',
      default: '',
    },
    sastAnalyzersDocumentationPath: {
      from: 'sastAnalyzersDocumentationPath',
      default: '',
    },
    securityConfigurationPath: {
      from: 'securityConfigurationPath',
      default: '',
    },
    projectPath: {
      from: 'projectPath',
      default: '',
    },
  },
  props: {
    // A SastCiConfiguration GraphQL object
    sastCiConfiguration: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      globalConfiguration: cloneDeep(this.sastCiConfiguration.global.nodes),
      pipelineConfiguration: cloneDeep(this.sastCiConfiguration.pipeline.nodes),
      analyzersConfiguration: this.glFeatures.sastConfigurationUiAnalyzers
        ? cloneDeep(this.sastCiConfiguration.analyzers.nodes)
        : [],
      hasSubmissionError: false,
      isSubmitting: false,
    };
  },
  computed: {
    shouldRenderAnalyzersSection() {
      return Boolean(
        this.glFeatures.sastConfigurationUiAnalyzers && this.analyzersConfiguration.length > 0,
      );
    },
  },
  methods: {
    onSubmit() {
      this.isSubmitting = true;
      this.hasSubmissionError = false;

      return this.$apollo
        .mutate({
          mutation: configureSastMutation,
          variables: {
            input: {
              projectPath: this.projectPath,
              configuration: this.getMutationConfiguration(),
            },
          },
        })
        .then(({ data }) => {
          const { errors, successPath } = data.configureSast;

          if (errors.length > 0 || !successPath) {
            // eslint-disable-next-line @gitlab/require-i18n-strings
            throw new Error('SAST merge request creation mutation failed');
          }

          redirectTo(successPath);
        })
        .catch(error => {
          this.isSubmitting = false;
          this.hasSubmissionError = true;
          Sentry.captureException(error);
        });
    },
    getMutationConfiguration() {
      const configuration = {
        global: this.globalConfiguration.map(toSastCiConfigurationEntityInput),
        pipeline: this.pipelineConfiguration.map(toSastCiConfigurationEntityInput),
      };

      if (this.glFeatures.sastConfigurationUiAnalyzers) {
        configuration.analyzers = this.analyzersConfiguration.map(
          toSastCiConfigurationAnalyzerEntityInput,
        );
      }

      return configuration;
    },
    onAnalyzerChange(name, updatedAnalyzer) {
      const index = this.analyzersConfiguration.findIndex(analyzer => analyzer.name === name);
      if (index === -1) {
        return;
      }

      this.analyzersConfiguration.splice(index, 1, updatedAnalyzer);
    },
  },
  i18n: {
    submissionError: s__(
      'SecurityConfiguration|An error occurred while creating the merge request.',
    ),
    submitButton: s__('SecurityConfiguration|Create Merge Request'),
    cancelButton: __('Cancel'),
    help: __('Help'),
    analyzersHeading: s__('SecurityConfiguration|SAST Analyzers'),
    analyzersSubHeading: s__(
      `SecurityConfiguration|By default, all analyzers are applied in order to
      cover all languages across your project, and only run if the language is
      detected in the Merge Request.`,
    ),
  },
};
</script>

<template>
  <form @submit.prevent="onSubmit">
    <dynamic-fields v-model="globalConfiguration" class="gl-m-0" />
    <dynamic-fields v-model="pipelineConfiguration" class="gl-m-0" />

    <expandable-section
      v-if="shouldRenderAnalyzersSection"
      class="gl-mb-5"
      data-testid="analyzers-section"
    >
      <template #heading>
        {{ $options.i18n.analyzersHeading }}
        <gl-link
          target="_blank"
          :href="sastAnalyzersDocumentationPath"
          :aria-label="$options.i18n.help"
        >
          <gl-icon name="question" />
        </gl-link>
      </template>

      <template #subheading>
        {{ $options.i18n.analyzersSubHeading }}
      </template>

      <analyzer-configuration
        v-for="analyzer in analyzersConfiguration"
        :key="analyzer.name"
        :entity="analyzer"
        @input="onAnalyzerChange(analyzer.name, $event)"
      />
    </expandable-section>

    <hr v-else />

    <gl-alert v-if="hasSubmissionError" class="gl-mb-5" variant="danger" :dismissible="false">{{
      $options.i18n.submissionError
    }}</gl-alert>

    <div class="gl-display-flex">
      <gl-button
        ref="submitButton"
        class="gl-mr-3 js-no-auto-disable"
        :loading="isSubmitting"
        type="submit"
        variant="success"
        category="primary"
        >{{ $options.i18n.submitButton }}</gl-button
      >

      <gl-button ref="cancelButton" :href="securityConfigurationPath">{{
        $options.i18n.cancelButton
      }}</gl-button>
    </div>
  </form>
</template>
