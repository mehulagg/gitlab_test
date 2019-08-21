<script>
import iconBuildStatus from '../svg/icon_build_status.svg';
import iconBranch from '../svg/icon_branch.svg';
import limitWarning from './limit_warning_component.vue';
import totalTime from './total_time_component.vue';
import icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    totalTime,
    limitWarning,
    icon,
  },
  props: {
    items: {
      type: Array,
      default: () => [],
    },
    stage: {
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    iconBuildStatus() {
      return iconBuildStatus;
    },
    iconBranch() {
      return iconBranch;
    },
  },
};
</script>
<template>
  <div>
    <div class="events-description">
      {{ stage.description }}
      <limit-warning :count="items.length" />
    </div>
    <ul class="stage-event-list">
      <li
        v-for="({ id, url, name, branch, commitUrl, shortSha, date, totalTime }, i) in items"
        :key="i"
        class="stage-event-item item-build-component"
      >
        <div class="item-details">
          <h5 class="item-title">
            <span class="icon-build-status" v-html="iconBuildStatus"></span>
            <a :href="url" class="item-build-name">{{ name }}</a> &middot;
            <a :href="url" class="pipeline-id">#{{ id }}</a>
            <icon :size="16" name="fork" />
            <a :href="branch.url" class="ref-name">{{ branch.name }}</a>
            <span class="icon-branch" v-html="iconBranch"></span>
            <a :href="commitUrl" class="commit-sha">{{ shortSha }}</a>
          </h5>
          <span>
            <a :href="url" class="issue-date">{{ date }}</a>
          </span>
        </div>
        <div class="item-time">
          <total-time :time="totalTime" />
        </div>
      </li>
    </ul>
  </div>
</template>
