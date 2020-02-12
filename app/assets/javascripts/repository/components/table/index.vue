<script>
import { GlSkeletonLoading } from '@gitlab/ui';
import { sprintf, __ } from '../../../locale';
import getRefMixin from '../../mixins/get_ref';
import getProjectPath from '../../queries/getProjectPath.query.graphql';
import TableRow from './row.vue';
import ParentRow from './parent_row.vue';

export default {
  components: {
    GlSkeletonLoading,
    TableRow,
    ParentRow,
  },
  mixins: [getRefMixin],
  apollo: {
    projectPath: {
      query: getProjectPath,
    },
  },
  props: {
    path: {
      type: String,
      required: true,
    },
    entries: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
    loadingPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      projectPath: '',
    };
  },
  computed: {
    tableCaption() {
      if (this.isLoading) {
        return sprintf(
          __(
            'Loading files, directories, and submodules in the path %{path} for commit reference %{ref}',
          ),
          { path: this.path, ref: this.ref },
        );
      }

      return sprintf(
        __('Files, directories, and submodules in the path %{path} for commit reference %{ref}'),
        { path: this.path, ref: this.ref },
      );
    },
    showParentRow() {
      return !this.isLoading && ['', '/'].indexOf(this.path) === -1;
    },
  },
};
</script>

<template>
  <div class="tree-content-holder">
    <div class="table-holder bordered-box">
      <table :aria-label="tableCaption" class="table tree-table qa-file-tree" aria-live="polite">
        <thead>
          <tr>
            <th class="tree-list-row gl-font-size-0">
              <div class="d-inline-block tree-list-col-1">{{ s__('ProjectFileTree|Name') }}</div>
              <div class="d-inline-block tree-list-col-2">{{ __('Last commit') }}</div>
              <div class="d-inline-block tree-list-col-3 text-right">{{ __('Last update') }}</div>
            </th>
          </tr>
        </thead>
        <tbody>
          <parent-row
            v-show="showParentRow"
            :commit-ref="ref"
            :path="path"
            :loading-path="loadingPath"
          />
          <template v-for="val in entries">
            <table-row
              v-for="entry in val"
              :id="entry.id"
              :key="`${entry.flatPath}-${entry.id}`"
              :sha="entry.sha"
              :project-path="projectPath"
              :current-path="path"
              :name="entry.name"
              :path="entry.flatPath"
              :type="entry.type"
              :url="entry.webUrl"
              :submodule-tree-url="entry.treeUrl"
              :lfs-oid="entry.lfsOid"
              :loading-path="loadingPath"
            />
          </template>
          <template v-if="isLoading">
            <tr v-for="i in 5" :key="i" aria-hidden="true">
              <td class="tree-list-row gl-font-size-0">
                <div class="tree-list-col-1 d-inline-block">
                  <gl-skeleton-loading :lines="1" class="h-auto" />
                </div>
                <div class="tree-list-col-2 d-inline-block">
                  <gl-skeleton-loading :lines="1" class="h-auto" />
                </div>
                <div class="tree-list-col-3 d-inline-block">
                  <gl-skeleton-loading :lines="1" class="ml-auto h-auto w-50" />
                </div>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style>
.tree-list-col-1 {
  width: 30%;
}

.tree-list-col-2 {
  width: 55%;
}

.tree-list-col-3 {
  width: 15%;
}

.tree-list-row * {
  font-size: 0.875rem;
}

.tree-list-row a:not(.tree-list-link),
.tree-list-row time {
  position: relative;
  z-index: 2;
}

.tree-list-link::before {
  content: '';
  position: absolute;
  width: 100%;
  height: 100%;
  left: 0;
  top: 0;
  z-index: 1;
}
</style>
