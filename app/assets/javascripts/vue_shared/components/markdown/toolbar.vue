<script>
import { GlButton, GlLink, GlLoadingIcon, GlSprintf, GlIcon, GlPopover } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlLink,
    GlLoadingIcon,
    GlSprintf,
    GlIcon,
    GlPopover,
  },
  props: {
    markdownDocsPath: {
      type: String,
      required: true,
    },
    quickActionsDocsPath: {
      type: String,
      required: false,
      default: '',
    },
    canAttachFile: {
      type: Boolean,
      required: false,
      default: true,
    },
    lineContent: {
      type: String,
      required: false,
      default: '',
    },
    canSuggest: {
      type: Boolean,
      required: false,
      default: true,
    },
    showSuggestPopover: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    hasQuickActionsDocsPath() {
      return this.quickActionsDocsPath !== '';
    },
  },
  mdSuggestion: ['```suggestion:-0+0', `{text}`, '```'].join('\n'),
};
</script>

<template>
  <div class="comment-toolbar clearfix">
    <div class="toolbar-text">
      <template v-if="!hasQuickActionsDocsPath && markdownDocsPath">
        <gl-link :href="markdownDocsPath" target="_blank">{{
          __('Markdown is supported')
        }}</gl-link>
      </template>
      <template v-if="hasQuickActionsDocsPath && markdownDocsPath">
        <gl-sprintf
          :message="
            __(
              '%{markdownDocsLinkStart}Markdown%{markdownDocsLinkEnd} and %{quickActionsDocsLinkStart}quick actions%{quickActionsDocsLinkEnd} are supported',
            )
          "
        >
          <template #markdownDocsLink="{content}">
            <gl-link :href="markdownDocsPath" target="_blank">{{ content }}</gl-link>
          </template>
          <template #quickActionsDocsLink="{content}">
            <gl-link :href="quickActionsDocsPath" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </template>
    </div>
    <span v-if="canAttachFile" class="uploading-container">
      <span class="uploading-progress-container hide">
        <template>
          <gl-icon name="media" :size="16" class="gl-vertical-align-text-bottom" />
        </template>
        <span class="attaching-file-message"></span>
        <!-- eslint-disable-next-line @gitlab/vue-require-i18n-strings -->
        <span class="uploading-progress">0%</span>
        <gl-loading-icon inline class="align-text-bottom" />
      </span>
      <span class="uploading-error-container hide">
        <span class="uploading-error-icon">
          <template>
            <gl-icon name="media" :size="16" class="gl-vertical-align-text-bottom" />
          </template>
        </span>
        <span class="uploading-error-message"></span>

        <gl-sprintf
          :message="
            __(
              '%{retryButtonStart}Try again%{retryButtonEnd} or %{newFileButtonStart}attach a new file%{newFileButtonEnd}',
            )
          "
        >
          <template #retryButton="{content}">
            <button class="retry-uploading-link" type="button">{{ content }}</button>
          </template>
          <template #newFileButton="{content}">
            <button class="attach-new-file markdown-selector" type="button">{{ content }}</button>
          </template>
        </gl-sprintf>
      </span>
      <gl-button class="markdown-selector button-attach-file" variant="link">
        <template>
          <gl-icon name="media" :size="16" />
        </template>
        <span class="text-attach-file">{{ __('Attach a file') }}</span>
      </gl-button>
      <gl-button class="btn btn-default btn-sm hide button-cancel-uploading-files" variant="link">
        {{ __('Cancel') }}
      </gl-button>
    </span>
    <template v-if="canSuggest">
      <gl-button
        ref="suggestButton"
        variant="link"
        class="markdown-selector js-md float-right mr-2"
        :data-md-tag="$options.mdSuggestion"
        data-md-cursor-offset="4"
        :data-md-tag-content="lineContent"
        data-md-prepend="true"
        data-testid="suggestBtn"
      >
        <gl-icon name="doc-code" :size="16" />
        {{ __('Suggest changes') }}
      </gl-button>
      <gl-popover
        v-if="showSuggestPopover"
        show
        :target="() => $refs.suggestButton.$el"
        :css-classes="['diff-suggest-popover']"
        placement="top"
        triggers="manual"
      >
        <strong>{{ __('New! Suggest changes directly') }}</strong>
        <p class="mb-2">
          {{
            __('Suggest code changes which can be immediately applied in one click. Try it out!')
          }}
        </p>
        <gl-button variant="info" size="small" @click="() => $emit('handleSuggestDismissed')">
          {{ __('Got it') }}
        </gl-button>
      </gl-popover>
    </template>
  </div>
</template>
