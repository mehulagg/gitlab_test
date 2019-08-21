<script>
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import iconBranch from '../svg/icon_branch.svg';
import LimitWarning from './limit_warning_component.vue';
import totalTime from './total_time_component.vue';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    UserAvatarImage,
    totalTime,
    LimitWarning,
    Icon,
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
        v-for="({ id, author, url, branch, name, commitUrl, shortSha, date, totalTime },
        i) in items"
        :key="i"
        class="stage-event-item item-build-component"
      >
        <div class="item-details">
          <!-- FIXME: Pass an alt attribute here for accessibility -->
          <user-avatar-image :img-src="author.avatarUrl" />
          <h5 class="item-title">
            <a :href="url" class="pipeline-id">#{{ id }}</a>
            <icon :size="16" name="fork" />
            <a :href="branch.url" class="ref-name">{{ branch.name }}</a>
            <span class="icon-branch" v-html="iconBranch"></span>
            <a :href="commitUrl" class="commit-sha">{{ shortSha }}</a>
          </h5>
          <span>
            <a :href="url" class="build-date">{{ date }}</a>
            {{ s__('ByAuthor|by') }}
            <a :href="author.webUrl" class="issue-author-link">{{ author.name }}</a>
          </span>
        </div>
        <div class="item-time">
          <total-time :time="totalTime" />
        </div>
      </li>
    </ul>
  </div>
</template>
