1<script>
import { s__, sprintf } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import {
  GlButton,
  GlModal,
  GlSprintf,
  GlTooltipDirective as GlTooltip,
  GlModalDirective,
} from '@gitlab/ui';

export default {
  components: { GlButton, GlModal, GlSprintf },
  directives: { GlTooltip, GlModal: GlModalDirective },
  props: {
    userLists: {
      type: Array,
      required: true,
    },
  },
  mixins: [timeagoMixin],
  translations: {
    createdTimeago: s__('created %{timeago}'),
    deleteListTitle: s__('Delete %{name}?'),
    deleteListMessage: s__('User list %{name} will be removed. Are you sure?'),
  },
  modal: {
    id: 'deleteListModal',
    actionPrimary: {
      text: s__('Delete user list'),
      attributes: { variant: 'danger', 'data-testid': 'modal-confirm' },
    },
  },
  data() {
    return {
      deleteUserList: null,
    };
  },
  computed: {
    deleteListName() {
      return this.deleteUserList?.name;
    },
    modalTitle() {
      return sprintf(this.$options.translations.deleteListTitle, {
        name: this.deleteListName,
      });
    },
  },
  methods: {
    createdTimeago(list) {
      return sprintf(this.$options.translations.createdTimeago, {
        timeago: this.timeFormatted(list.created_at),
      });
    },
    displayList(list) {
      return list.user_xids.replace(/,/g, ', ');
    },
    onDelete() {
      this.$emit('delete', this.deleteUserList);
    },
    confirmDeleteList(list) {
      this.deleteUserList = list;
    },
  },
};
</script>
<template>
  <div>
    <div
      v-for="list in userLists"
      :key="list.id"
      data-testid="list"
      class="gl-border-b-solid gl-border-gray-100 gl-border-b-1 gl-py-4 gl-display-flex gl-justify-content-space-between"
    >
      <div class="gl-display-flex gl-flex-direction-column">
        <span data-testid="listName" class="gl-font-weight-bold gl-mb-2">{{ list.name }}</span>
        <span
          v-gl-tooltip
          :title="tooltipTitle(list.created_at)"
          data-testid="listTimestamp"
          class="gl-text-gray-500 gl-mb-2"
        >
          {{ createdTimeago(list) }}
        </span>
        <span data-testid="listIds">{{ displayList(list) }}</span>
      </div>
      <gl-button
        v-gl-modal="$options.modal.id"
        class="gl-align-self-start"
        variant="danger"
        icon="remove"
        @click="confirmDeleteList(list)"
      >
      </gl-button>
    </div>
    <gl-modal
      :title="modalTitle"
      :modal-id="$options.modal.id"
      :action-primary="$options.modal.actionPrimary"
      static
      @primary="onDelete"
    >
      <gl-sprintf :message="$options.translations.deleteListMessage">
        <template #name>
          <b>{{ deleteListName }}</b>
        </template>
      </gl-sprintf>
    </gl-modal>
  </div>
</template>
