<script>
import { escapeRegExp } from 'lodash';
import { GlBadge, GlLink, GlSkeletonLoading, GlTooltipDirective, GlLoadingIcon } from '@gitlab/ui';
import TimeagoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import Icon from '~/vue_shared/components/icon.vue';
import { getIconName } from '../../utils/icon';
import getRefMixin from '../../mixins/get_ref';
import getCommit from '../../queries/getCommit.query.graphql';

export default {
  components: {
    GlBadge,
    GlLink,
    GlSkeletonLoading,
    GlLoadingIcon,
    TimeagoTooltip,
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  apollo: {
    commit: {
      query: getCommit,
      variables() {
        return {
          fileName: this.name,
          type: this.type,
          path: this.currentPath,
          projectPath: this.projectPath,
        };
      },
    },
  },
  mixins: [getRefMixin],
  props: {
    id: {
      type: String,
      required: true,
    },
    sha: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    currentPath: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    url: {
      type: String,
      required: false,
      default: null,
    },
    lfsOid: {
      type: String,
      required: false,
      default: null,
    },
    submoduleTreeUrl: {
      type: String,
      required: false,
      default: null,
    },
    loadingPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      commit: null,
    };
  },
  computed: {
    routerLinkTo() {
      return this.isFolder ? { path: `/-/tree/${escape(this.ref)}/${escape(this.path)}` } : null;
    },
    iconName() {
      return `fa-${getIconName(this.type, this.path)}`;
    },
    isFolder() {
      return this.type === 'tree';
    },
    isSubmodule() {
      return this.type === 'commit';
    },
    linkComponent() {
      return this.isFolder ? 'router-link' : 'a';
    },
    fullPath() {
      return this.path.replace(new RegExp(`^${escapeRegExp(this.currentPath)}/`), '');
    },
    shortSha() {
      return this.sha.slice(0, 8);
    },
    hasLockLabel() {
      return this.commit && this.commit.lockLabel;
    },
  },
};
</script>

<template>
  <tr class="tree-item">
    <td class="tree-item-file-name tree-list-row gl-font-size-0 position-relative">
      <div class="d-inline-block tree-list-col-1">
        <gl-loading-icon
          v-if="path === loadingPath"
          size="sm"
          inline
          class="d-inline-block align-text-bottom fa-fw"
        />
        <i v-else :aria-label="type" role="img" :class="iconName" class="fa fa-fw"></i>
        <component
          :is="linkComponent"
          :to="routerLinkTo"
          :href="url"
          class="str-truncated tree-list-link"
        >
          {{ fullPath }}
        </component>
        <!-- eslint-disable-next-line @gitlab/vue-i18n/no-bare-strings -->
        <gl-badge v-if="lfsOid" variant="default" class="label-lfs ml-1">LFS</gl-badge>
        <template v-if="isSubmodule">
          @ <gl-link :href="submoduleTreeUrl" class="commit-sha">{{ shortSha }}</gl-link>
        </template>
        <icon
          v-if="hasLockLabel"
          v-gl-tooltip
          :title="commit.lockLabel"
          name="lock"
          :size="12"
          class="ml-2 vertical-align-middle"
        />
      </div>
      <div class="d-inline-block position-relative tree-list-col-2">
        <gl-link
          v-if="commit"
          :href="commit.commitPath"
          :title="commit.message"
          class="str-truncated-100 tree-commit-link"
        >
          {{ commit.message }}
        </gl-link>
        <gl-skeleton-loading v-else :lines="1" class="h-auto" />
      </div>
      <div class="d-inline-block position-relative text-right tree-list-col-3">
        <timeago-tooltip v-if="commit" :time="commit.committedDate" />
        <gl-skeleton-loading v-else :lines="1" class="ml-auto h-auto w-50" />
      </div>
    </td>
  </tr>
</template>
