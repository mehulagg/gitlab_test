<script>
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import LimitWarning from './limit_warning_component.vue';
import totalTime from './total_time_component.vue';

export default {
  components: {
    UserAvatarImage,
    LimitWarning,
    totalTime,
  },
  props: {
    items: {
      type: Array,
      required: true,
    },
    stage: {
      type: Object,
      required: true,
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
        v-for="({ iid, title, url, author, totalTime, createdAt }, i) in items"
        :key="i"
        class="stage-event-item"
      >
        <!-- TODO: should probably be slotted -->
        <div class="item-details">
          <!-- FIXME: Pass an alt attribute here for accessibility -->
          <user-avatar-image :img-src="author.avatarUrl" />
          <h5 class="item-title issue-title">
            <a :href="url" class="issue-title">{{ title }}</a>
          </h5>
          <a :href="url" class="issue-link">#{{ iid }}</a> &middot;
          <span>
            {{ s__('OpenedNDaysAgo|Opened') }}
            <a :href="url" class="issue-date">{{ createdAt }}</a>
          </span>
          <span>
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
