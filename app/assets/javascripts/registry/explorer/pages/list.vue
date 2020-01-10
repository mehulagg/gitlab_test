<script>
import { mapState, mapActions } from 'vuex';
import {
  GlLoadingIcon,
  GlEmptyState,
  GlPagination,
  GlTooltipDirective,
  GlButton,
  GlIcon,
  GlModal,
} from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import Tracking from '~/tracking';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import ProjectEmptyState from '../components/project_empty_state.vue';
import GroupEmptyState from '../components/group_empty_state.vue';

export default {
  name: 'RegistryListApp',
  components: {
    GlEmptyState,
    GlLoadingIcon,
    GlPagination,
    ProjectEmptyState,
    GroupEmptyState,
    ClipboardButton,
    GlButton,
    GlIcon,
    GlModal,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [Tracking.mixin()],
  data() {
    return {
      itemToDelete: {},
    };
  },
  computed: {
    ...mapState(['config', 'isLoading', 'images', 'pagination']),
    currentPage: {
      get() {
        return this.pagination.page;
      },
      set(page) {
        this.requestImagesList({ page });
      },
    },
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
  methods: {
    ...mapActions(['requestImagesList', 'requestDeleteImage']),
    deleteImage(item) {
      this.itemToDelete = item;
      this.$refs.deleteModal.show();
    },
    handleDeleteRepository() {
      this.track('confirm_delete');
      this.requestDeleteImage(this.itemToDelete.destroy_path);
      this.itemToDelete = {};
    },
    encodeListItem({ tags_path }) {
      return window.btoa(tags_path);
    },
  },
};
</script>
<template>
  <div class="position-absolute w-100 slide-enter-from-element">
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

      <div class="d-flex flex-column">
        <div
          v-for="(listItem, index) in images"
          :key="index"
          :class="{
            'd-flex justify-content-between align-items-center py-2 border-bottom': true,
            'border-top': index === 0,
          }"
        >
          <div>
            <router-link :to="{ name: 'details', params: { id: encodeListItem(listItem) } }">
              {{ listItem.path }}
            </router-link>
            <clipboard-button
              v-if="listItem.location"
              :text="listItem.location"
              :title="listItem.location"
              css-class="btn-default btn-transparent btn-clipboard"
            />
          </div>
          <div class="controls d-none d-sm-block">
            <gl-button
              v-gl-tooltip
              :disabled="!listItem.destroy_path"
              :title="s__('ContainerRegistry|Remove repository')"
              :aria-label="s__('ContainerRegistry|Remove repository')"
              class="btn-inverted"
              variant="danger"
              @click="deleteImage(listItem)"
            >
              <gl-icon name="remove" />
            </gl-button>
          </div>
        </div>
      </div>
      <gl-pagination
        v-model="currentPage"
        :per-page="pagination.perPage"
        :total-items="pagination.total"
        align="center"
        class="w-100 mt-2"
      />
    </div>
    <project-empty-state v-else-if="!config.isGroupPage" />
    <group-empty-state v-else-if="config.isGroupPage" />
    <gl-modal
      ref="deleteModal"
      modal-id="delete-image-modal"
      ok-variant="danger"
      @ok="handleDeleteRepository"
      @cancel="track('cancel_delete')"
    >
      <template v-slot:modal-title>{{ s__('ContainerRegistry|Remove repository') }}</template>
      <p
        v-html="
          sprintf(
            s__(
              'ContainerRegistry|You are about to remove repository <b>%{title}</b>. Once you confirm, this repository will be permanently deleted.',
            ),
            { title: itemToDelete.path },
          )
        "
      ></p>
      <template v-slot:modal-ok>{{ __('Remove') }}</template>
    </gl-modal>
  </div>
</template>
