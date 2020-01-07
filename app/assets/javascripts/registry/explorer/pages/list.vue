<script>
import { mapState } from 'vuex';
import { GlLoadingIcon, GlEmptyState, GlPaginatedList } from '@gitlab/ui';
import ProjectEmptyState from '../components/project_empty_state.vue';
import GroupEmptyState from '../components/group_empty_state.vue';
import { s__, sprintf } from '~/locale';

export default {
  name: 'RegistryListApp',
  components: {
    GlEmptyState,
    GlLoadingIcon,
    GlPaginatedList,
    ProjectEmptyState,
    GroupEmptyState,
  },
  computed: {
    ...mapState(['config', 'isLoading', 'images']),
    dockerConnectionErrorText() {
      return sprintf(
        s__(`ContainerRegistry|We are having trouble connecting to Docker, which could be due to an
            issue with your project name or path.
            %{docLinkStart}More Information%{docLinkEnd}`),
        {
          docLinkStart: `<a href="${this.config.helpPagePath}#docker-connection-error" target="_blank">`,
          docLinkEnd: '</a>',
        },
        false,
      );
    },
    introText() {
      return sprintf(
        s__(`ContainerRegistry|With the Docker Container Registry integrated into GitLab, every
            project can have its own space to store its Docker images.
            %{docLinkStart}More Information%{docLinkEnd}`),
        {
          docLinkStart: `<a href="${this.config.helpPagePath}" target="_blank">`,
          docLinkEnd: '</a>',
        },
        false,
      );
    },
    noContainerImagesText() {
      return sprintf(
        s__(`ContainerRegistry|With the Container Registry, every project can have its own space to
            store its Docker images. %{docLinkStart}More Information%{docLinkEnd}`),
        {
          docLinkStart: `<a href="${this.config.helpPagePath}" target="_blank">`,
          docLinkEnd: '</a>',
        },
        false,
      );
    },
  },
};
</script>
<template>
  <div>
    <gl-empty-state
      v-if="config.characterError"
      :title="s__('ContainerRegistry|Docker connection error')"
      :svg-path="config.containersErrorImage"
    >
      <template #description>
        <p class="js-character-error-text" v-html="config.dockerConnectionErrorText"></p>
      </template>
    </gl-empty-state>

    <gl-loading-icon v-else-if="isLoading" size="md" class="prepend-top-16" />

    <div v-else-if="!isLoading && images.length">
      <h4>{{ s__('ContainerRegistry|Container Registry') }}</h4>
      <p v-html="introText"></p>
      <gl-paginated-list :list="images" :filterable="false" :filter="() => true">
        <template #default="{ listItem }">
          <router-link :to="{ name: 'details', params: { id: listItem.id } }">
            {{ listItem.path }}
          </router-link>
        </template>
      </gl-paginated-list>
    </div>
    <project-empty-state v-else-if="!config.isGroupPage" />
    <group-empty-state v-else-if="config.isGroupPage" />
  </div>
</template>
