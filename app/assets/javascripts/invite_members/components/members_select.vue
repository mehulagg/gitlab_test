<script>
import { GlLoadingIcon, GlIcon, GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import UsersSelect from '~/users_select';
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import Select2Select from '~/vue_shared/components/select2_select.vue';

export default {
  components: {
    UserAvatarImage,
    GlLoadingIcon,
    GlIcon,
    GlButton,
    Select2Select,
  },
  props: {
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
    label: {
      type: String,
      required: true,
      default: '',
    },
    placeholderText: {
      type: String,
      required: false,
      default: __('Search for members to invite'),
    },
    selected: {
      type: Object,
      required: false,
      default: () => null,
    },
    wrapperClass: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    hasValue() {
      return this.selected && this.selected.id > 0;
    },
    selectedId() {
      return this.selected ? this.selected.id : null;
    },
    select2Options() {
      return {
        data: this.selected,
        containerCssClass: 'gl-w-auto',
      };
    },
    targetMemberSelect: {
      get() {
        return this.selected;
      },
      set(value) {
        this.selected = user;
      },
    },
  },
  watch: {
    selected() {
      this.initSelect();
    },
  },
  mounted() {
    this.initSelect();
  },
  methods: {
    initSelect() {
      this.userDropdown = new UsersSelect(null, this.$refs.dropdown, {
        handleClick: this.selectUser,
      });
    },
    selectUser(user, isMarking) {
      this.selected = user;
    },

    
  },
};
</script>

<template>
  <div :class="wrapperClass" class="block">
    <div class="title gl-mb-3">
      {{ label }}
    </div>
    <div class="value">
      <div v-if="hasValue" class="media">
        <div class="align-center">
          <user-avatar-image :img-src="selected.avatar_url" :size="32" />
        </div>
        <div class="media-body">
          <div class="bold author">{{ selected.name }}</div>
          <div class="username">@{{ selected.username }}</div>
        </div>
      </div>
    </div>

    <div class="selectbox">
      <div class="dropdown gl-border-none">
        <button
          ref="dropdown"
          data-field-name="Members"
          :data-dropdown-title="placeholderText"
          :data-placeholder="placeholderText"
          :data-group-id="groupId"
          :data-selected="selectedId"
          class="dropdown-menu-toggle wide multiselect ajax-users-select"
          data-toggle="dropdown"
          aria-expanded="false"
          type="button"
        >
          <span class="dropdown-toggle-text">{{ placeholderText }}</span>
          <gl-icon
            name="chevron-down"
            class="gl-absolute gl-top-3 gl-right-3 gl-text-gray-500"
            :size="16"
          />
        </button>
        <div
          class="dropdown-menu dropdown-select dropdown-menu-paging dropdown-menu-user dropdown-menu-selectable dropdown-menu-author"
        >
          <div class="dropdown-input">
            <input
              autocomplete="off"
              class="dropdown-input-field"
              :placeholder="__('Search')"
              type="search"
            />
            <gl-icon
              name="search"
              class="dropdown-input-search gl-absolute gl-top-3 gl-right-5 gl-text-gray-300 gl-pointer-events-none"
            />
            <gl-icon
              name="close"
              class="dropdown-input-clear js-dropdown-input-clear gl-absolute gl-top-3 gl-right-5 gl-text-gray-500"
            />
          </div>
          <div class="dropdown-content"></div>
          <div class="dropdown-loading">
            <gl-loading-icon />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
