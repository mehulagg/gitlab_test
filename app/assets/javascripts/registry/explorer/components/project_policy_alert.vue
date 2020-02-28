<script>
import { GlAlert, GlSprintf, GlLink } from '@gitlab/ui';
import { mapState } from 'vuex';
import Api from '~/api';
import { formatDate, getDayDifference } from '~/lib/utils/datetime_utility';

export default {
  components: {
    GlAlert,
    GlSprintf,
    GlLink,
  },
  data() {
    return {
      policy: null,
    };
  },
  computed: {
    ...mapState(['config']),
    showAlert() {
      return this.policy?.enabled;
    },
    time() {
      console.log(getDayDifference(new Date(this.policy?.next_run_at), new Date()));
      return formatDate(this.policy?.next_run_at, 'mmm d, yyyy h:MMtt');
    },
  },
  mounted() {
    return Api.project(this.config.projectId).then(({ data }) => {
      this.policy = data?.container_expiration_policy;
    });
  },
};
</script>

<template>
  <gl-alert
    v-if="showAlert"
    :dismissible="false"
    :primary-button-text="__('Edit Settings')"
    :primary-button-link="config.settingsPath"
    :title="s__('ContainerRegistry|Retention policy has been Enabled')"
    class="my-2"
  >
    <gl-sprintf
      :message="
        s__(
          'ContainerRegistry|The retention and expiration policy for this container registry has been enabled and will run in %{time} for more infomration visit the %{linkStart}documentation%{linkEnd}',
        )
      "
    >
      <template #time>
        <strong>
          <time>{{ time }}</time>
        </strong>
      </template>
      <template #link="{content}">
        <gl-link :href="config.helpPagePath" target="_blank">
          {{ content }}
        </gl-link>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>
