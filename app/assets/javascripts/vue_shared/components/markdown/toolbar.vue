<script>
/* eslint-disable @gitlab/vue-require-i18n-strings */
import { GlLink, GlLoadingIcon, GlIcon, GlButton, GlPopover } from '@gitlab/ui';

export default {
  components: {
    GlLink,
    GlLoadingIcon,
    GlIcon,
    GlButton,
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
};
</script>

<template>
  <div class="comment-toolbar clearfix">
    <div class="toolbar-text">
      <template v-if="!hasQuickActionsDocsPath && markdownDocsPath">
        <gl-link :href="markdownDocsPath" target="_blank" tabindex="-1">{{
          __('Markdown is supported')
        }}</gl-link>
      </template>
      <template v-if="hasQuickActionsDocsPath && markdownDocsPath">
        <gl-link :href="markdownDocsPath" target="_blank" tabindex="-1">{{
          __('Markdown')
        }}</gl-link>
        and
        <gl-link :href="quickActionsDocsPath" target="_blank" tabindex="-1">{{
          __('quick actions')
        }}</gl-link>
        are supported
      </template>
    </div>
    <span v-if="canAttachFile" class="uploading-container">
      <span class="uploading-progress-container hide">
        <i class="fa fa-file-image-o toolbar-button-icon" aria-hidden="true"></i>
        <span class="attaching-file-message"></span>
        <span class="uploading-progress">0%</span>
        <gl-loading-icon inline class="align-text-bottom" />
      </span>
      <span class="uploading-error-container hide">
        <span class="uploading-error-icon">
          <i class="fa fa-file-image-o toolbar-button-icon" aria-hidden="true"></i>
        </span>
        <span class="uploading-error-message"></span>
        <button class="retry-uploading-link" type="button">{{ __('Try again') }}</button> or
        <button class="attach-new-file markdown-selector" type="button">
          {{ __('attach a new file') }}
        </button>
      </span>
      <button class="markdown-selector button-attach-file btn-link" tabindex="-1" type="button">
        <i class="fa fa-file-image-o toolbar-button-icon" aria-hidden="true"></i
        ><span class="text-attach-file">{{ __('Attach a file') }}</span>
      </button>
      <button class="btn btn-default btn-sm hide button-cancel-uploading-files" type="button">
        {{ __('Cancel') }}
      </button>
    </span>
    <template v-if="canSuggest">
      <gl-button
        ref="suggestButton"
        variant="link"
        class="link js-md float-right mr-2 toolbar-text"
        :data-md-tag="['```suggestion:-0+0', '{text}', '```'].join('\n')"
        data-md-cursor-offset="4"
        :data-md-tag-content="lineContent"
        data-md-prepend="true"
      >
        <gl-icon name="doc-code" :size="18" class="vertical-align-middle" />
        {{ __('Suggest changes') }}
      </gl-button>
      <gl-popover
        v-if="showSuggestPopover && $refs.suggestButton"
        :target="$refs.suggestButton"
        :css-classes="['diff-suggest-popover']"
        placement="bottom"
        :show="showSuggestPopover"
      >
        <strong>{{ __('New! Suggest changes directly') }}</strong>
        <p class="mb-2">
          {{
            __('Suggest code changes which can be immediately applied in one click. Try it out!')
          }}
        </p>
        <gl-button variant="primary" size="small" @click="() => $emit('handleSuggestDismissed')">
          {{ __('Got it') }}
        </gl-button>
      </gl-popover>
    </template>
  </div>
</template>
