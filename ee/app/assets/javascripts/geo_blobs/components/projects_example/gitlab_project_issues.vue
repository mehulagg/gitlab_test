<script>
import { GlCard } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';

export default {
  name: 'GitlabProjectIssues',
  components: {
    GlCard,
    Icon,
    UserAvatarImage,
  },
  props: {
    project: {
      type: Object,
      required: true,
    },
  },
  methods: {
    iconName(issue) {
      return issue.state === 'opened' ? 'issue-open' : 'issue-close';
    },
    iconClass(issue) {
      return issue.state === 'opened' ? 'text-success' : 'text-primary';
    },
  },
};
</script>

<template>
  <div>
    <h4>{{ __(`Last 5 Issues for ${project.name}`) }}</h4>
    <gl-card v-for="issue in project.issues.nodes" :key="issue.iid">
      <div class="d-flex align-items-center">
        <icon ref="state" class="mr-2" :name="iconName(issue)" :class="iconClass(issue)" />
        {{ issue.title }}
      </div>
      <template #footer>
        <div class="d-flex align-items-center">
          <user-avatar-image
            :img-src="issue.author.avatarUrl"
            :size="16"
            css-classes="mr-0 float-none"
            tooltip-placement="bottom"
            class="d-inline-block"
          >
            <span class="bold d-block">{{ __('Author') }}</span> {{ issue.author.name }}
            <span class="text-tertiary">@{{ issue.author.username }}</span>
          </user-avatar-image>
          <span class="pl-2">{{ issue.author.name }}</span>
        </div>
      </template>
    </gl-card>
  </div>
</template>

<style lang="scss" scoped></style>
