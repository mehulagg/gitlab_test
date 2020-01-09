<script>
import { mapState, mapActions } from 'vuex';
import {
  GlTable,
  GlFormCheckbox,
  GlButton,
  GlIcon,
  GlTooltipDirective,
  GlPagination,
  GlModal,
  GlLoadingIcon,
} from '@gitlab/ui';
import { n__, sprintf, s__ } from '~/locale';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import Tracking from '~/tracking';
import {
  LIST_KEY_TAG,
  LIST_LABEL_TAG,
  LIST_KEY_IMAGE_ID,
  LIST_LABEL_IMAGE_ID,
  LIST_KEY_SIZE,
  LIST_KEY_LAST_UPDATED,
  LIST_LABEL_LAST_UPDATED,
  LIST_LABEL_SIZE,
  LIST_KEY_ACTIONS,
  LIST_KEY_CHECKBOX,
} from '../constants';

export default {
  components: {
    GlTable,
    GlFormCheckbox,
    GlButton,
    GlIcon,
    ClipboardButton,
    GlPagination,
    GlModal,
    GlLoadingIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin, Tracking.mixin()],
  data() {
    return {
      selectedItems: [],
      itemsToBeDeleted: [],
      selectAllChecked: false,
      modalDescription: '',
    };
  },
  computed: {
    ...mapState(['tags', 'tagsPagination', 'isLoading']),
    fields() {
      return [
        { key: LIST_KEY_CHECKBOX, label: '' },
        { key: LIST_KEY_TAG, label: LIST_LABEL_TAG },
        { key: LIST_KEY_IMAGE_ID, label: LIST_LABEL_IMAGE_ID },
        { key: LIST_KEY_SIZE, label: LIST_LABEL_SIZE },
        { key: LIST_KEY_LAST_UPDATED, label: LIST_LABEL_LAST_UPDATED },
        { key: LIST_KEY_ACTIONS, label: '' },
      ];
    },
    isMultiDelete() {
      return this.itemsToBeDeleted.length > 1;
    },
    modalAction() {
      return n__(
        'ContainerRegistry|Remove tag',
        'ContainerRegistry|Remove tags',
        this.isMultiDelete ? this.itemsToBeDeleted.length : 1,
      );
    },
    currentPage: {
      get() {
        return this.tagsPagination.page;
      },
      set(page) {
        this.requestTagsList({ pagination: { page }, id: this.$route.params.id });
      },
    },
  },
  methods: {
    ...mapActions(['requestTagsList', 'requestDeleteTag', 'requestDeleteTags']),
    setModalDescription(itemIndex = -1) {
      if (itemIndex === -1) {
        this.modalDescription = sprintf(
          s__(`ContainerRegistry|You are about to remove <b>%{count}</b> tags. Are you sure?`),
          { count: this.itemsToBeDeleted.length },
        );
      } else {
        const { path } = this.tags[itemIndex];

        this.modalDescription = sprintf(
          s__(`ContainerRegistry|You are about to remove <b>%{title}</b>. Are you sure?`),
          { title: `${path}` },
        );
      }
    },
    formatSize(size) {
      return numberToHumanSize(size);
    },
    layers(layers) {
      return layers ? n__('%d layer', '%d layers', layers) : '';
    },
    onSelectAllChange() {
      if (this.selectAllChecked) {
        this.deselectAll();
      } else {
        this.selectAll();
      }
    },
    selectAll() {
      this.selectedItems = this.tags.map((x, index) => index);
      this.selectAllChecked = true;
    },
    deselectAll() {
      this.selectedItems = [];
      this.selectAllChecked = false;
    },
    updateselectedItems(index) {
      const delIndex = this.selectedItems.findIndex(x => x === index);

      if (delIndex > -1) {
        this.selectedItems.splice(delIndex, 1);
        this.selectAllChecked = false;
      } else {
        this.selectedItems.push(index);

        if (this.selectedItems.length === this.tags.length) {
          this.selectAllChecked = true;
        }
      }
    },
    deleteSingleItem(index) {
      this.setModalDescription(index);
      this.itemsToBeDeleted = [index];
      this.track('click_button');
      this.$refs.deleteModal.show();
    },
    deleteMultipleItems() {
      this.itemsToBeDeleted = [...this.selectedItems];
      if (this.selectedItems.length === 1) {
        this.setModalDescription(this.itemsToBeDeleted[0]);
      } else if (this.selectedItems.length > 1) {
        this.setModalDescription();
      }
      this.track('click_button');
      this.$refs.deleteModal.show();
    },
    handleSingleDelete(itemToDelete) {
      this.itemsToBeDeleted = [];
      this.requestDeleteTag({ tag: itemToDelete, imageId: this.$route.params.id });
    },
    handleMultipleDelete() {
      const { itemsToBeDeleted } = this;
      this.itemsToBeDeleted = [];
      this.selectedItems = [];

      this.requestDeleteTags({
        ids: itemsToBeDeleted.map(x => this.tags[x].name),
        imageId: this.$route.params.id,
      });
    },
    onDeletionConfirmed() {
      this.track('confirm_delete');
      if (this.isMultiDelete) {
        this.handleMultipleDelete();
      } else {
        const index = this.itemsToBeDeleted[0];
        this.handleSingleDelete(this.tags[index]);
      }
    },
  },
};
</script>

<template>
  <div class="my-3 position-absolute w-100 slide-enter-to-element">
    <div class="d-flex prepend-top-8 align-items-center">
      <gl-button :to="{ name: 'list' }" size="sm" class="append-right-default">
        <gl-icon name="angle-left" />
      </gl-button>
      <h4>{{ s__('ContainerRegistry|Tag details') }}</h4>
    </div>
    <gl-loading-icon v-if="isLoading" />
    <template v-else>
      <gl-table :items="tags" :fields="fields" stacked="md">
        <template #HEAD_checkbox>
          <gl-form-checkbox :checked="selectAllChecked" @change="onSelectAllChange" />
        </template>
        <template #checkbox="{index}">
          <gl-form-checkbox
            :checked="selectedItems.includes(index)"
            @change="updateselectedItems(index)"
          />
        </template>
        <template #name="{item}">
          <span>
            {{ item.name }}
          </span>
          <clipboard-button
            v-if="item.location"
            :title="item.location"
            :text="item.location"
            css-class="btn-default btn-transparent btn-clipboard"
          />
        </template>
        <template #short_revision="{value}">
          <span>
            {{ value }}
          </span>
        </template>
        <template #total_size="{item}">
          <span>
            {{ formatSize(item.total_size) }}
            <template v-if="item.total_size && item.layers"
              >&middot;</template
            >
            {{ layers(item.layers) }}
          </span>
        </template>
        <template #created_at="{value}">
          <span>
            {{ timeFormatted(value) }}
          </span>
        </template>
        <template #HEAD_actions>
          <gl-button
            ref="bulkDeleteButton"
            v-gl-tooltip
            :disabled="!selectedItems || selectedItems.length === 0"
            class="float-right"
            variant="danger"
            :title="s__('ContainerRegistry|Remove selected tags')"
            :aria-label="s__('ContainerRegistry|Remove selected tags')"
            @click="deleteMultipleItems()"
          >
            <gl-icon name="remove" />
          </gl-button>
        </template>
        <template #actions="{index}">
          <gl-button
            :title="s__('ContainerRegistry|Remove tag')"
            :aria-label="s__('ContainerRegistry|Remove tag')"
            variant="danger"
            class="js-delete-registry-row float-right btn-inverted btn-border-color btn-icon"
            @click="deleteSingleItem(index)"
          >
            <gl-icon name="remove" />
          </gl-button>
        </template>
      </gl-table>
      <gl-pagination
        v-model="currentPage"
        :per-page="tagsPagination.perPage"
        :total-items="tagsPagination.total"
        align="center"
        class="w-100"
      />
      <gl-modal
        ref="deleteModal"
        modal-id="delete-tag-modal"
        ok-variant="danger"
        @ok="onDeletionConfirmed"
        @cancel="track('cancel_delete')"
      >
        <template v-slot:modal-title>{{ modalAction }}</template>
        <template v-slot:modal-ok>{{ modalAction }}</template>
        <p v-html="modalDescription"></p>
      </gl-modal>
    </template>
  </div>
</template>
