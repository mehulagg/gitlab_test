<script>
import { n__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    Icon,
    TimeAgo,
  },
  props: {
    versions: {
      type: Array,
      required: true,
    },
    isActive: {
      type: Function,
      required: true,
    },
  },
  computed: {
    selectedVersionName() {
      const selectedVersion = this.versions.find(x => this.isActive(x));
      if (!selectedVersion) return '';

      return selectedVersion.versionName;
    },
  },
  methods: {
    commitsText(version) {
      return n__(`%d commit,`, `%d commits,`, version.commits_count);
    },
  },
};
</script>

<template>
  <span class="dropdown inline">
    <a
      class="dropdown-menu-toggle btn btn-default w-100"
      data-toggle="dropdown"
      aria-expanded="false"
    >
      <span> {{ selectedVersionName }} </span>
      <icon :size="12" name="angle-down" class="position-absolute" />
    </a>
    <div class="dropdown-menu dropdown-select dropdown-menu-selectable">
      <div class="dropdown-content">
        <ul>
          <li v-for="version in versions" :key="version.id">
            <a :class="{ 'is-active': isActive(version) }" :href="version.href">
              <div>
                <strong>
                  {{ version.versionName }}
                </strong>
              </div>
              <div>
                <small class="commit-sha"> {{ version.short_commit_sha }} </small>
              </div>
              <div>
                <small v-if="version.created_at">
                  {{ commitsText(version) }}
                  <time-ago :time="version.created_at" class="js-timeago" />
                </small>
              </div>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </span>
</template>

<style>
.dropdown {
  min-width: 0;
  max-height: 170px;
}
</style>
