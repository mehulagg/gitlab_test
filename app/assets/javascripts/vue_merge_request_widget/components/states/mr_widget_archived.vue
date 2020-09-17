<script>
import statusIcon from '../mr_widget_status_icon.vue';
import { GlButton } from '@gitlab/ui';

export default {
  name: 'MRWidgetArchived',
  components: {
    statusIcon,
    GlButton,
  },
};
</script>
<template>
  <div class="mr-widget-body media">
    <div class="space-children">
      <status-icon status="warning" />
      <gl-button category="secondary" variant="success" disabled="true">
        {{ s__('mrWidget|Merge') }}
      </gl-button>
    </div>
    <div class="media-body">
      <span class="bold">
        {{ s__('mrWidget|This project is archived, write access has been disabled') }}
      </span>
    </div>
  </div>
</template>
