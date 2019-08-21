<script>
import userAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import limitWarning from './limit_warning_component.vue';
import totalTime from './total_time_component.vue';
import icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    userAvatarImage,
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
        v-for="({ iid, name, author, title, url, createdAt, state, branch, totalTime }, i) in items"
        :key="i"
        class="stage-event-item"
      >
        <div class="item-details">
          <!-- FIXME: Pass an alt attribute here for accessibility -->
          <user-avatar-image :img-src="author.avatarUrl" />
          <h5 class="item-title merge-request-title">
            <a :href="url">{{ title }}</a>
          </h5>
          <a :href="url" class="issue-link">!{{ iid }}</a> &middot;
          <span>
            {{ s__('OpenedNDaysAgo|Opened') }}
            <a :href="url" class="issue-date">{{ createdAt }}</a>
          </span>
          <span>
            {{ s__('ByAuthor|by') }}
            <a :href="author.webUrl" class="issue-author-link">
              {{ author.name }}
            </a>
          </span>
          <template v-if="state === 'closed'">
            <span class="merge-request-state">
              <i class="fa fa-ban" aria-hidden="true"></i>
              {{ state.toUpperCase() }}
            </span>
          </template>
          <template v-else>
            <span v-if="branch" class="merge-request-branch">
              <icon :size="16" name="fork" />
              <a :href="branch.url">{{ branch.name }}</a>
            </span>
          </template>
        </div>
        <div class="item-time">
          <total-time :time="totalTime" />
        </div>
      </li>
    </ul>
  </div>
</template>
