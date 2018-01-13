import Flash from '~/flash';
import CreateItemDropdown from '~/create_item_dropdown';
import { ACCESS_LEVELS, LEVEL_TYPES } from './constants';
import ProtectedTagAccessDropdown from './protected_tag_access_dropdown';

export default class ProtectedTagCreate {
  constructor() {
    this.$form = $('.js-new-protected-tag');
    this.buildDropdowns();
    this.$tagInput = this.$form.find('input[name="protected_tag[name]"]');
    this.bindEvents();
  }

  bindEvents() {
    this.$form.on('submit', this.onFormSubmit.bind(this));
  }

  buildDropdowns() {
    const $allowedToCreateDropdown = this.$form.find('.js-allowed-to-create');

    // Cache callback
    this.onSelectCallback = this.onSelect.bind(this);

    // Allowed to Create dropdown
    this[`${ACCESS_LEVELS.CREATE}_dropdown`] = new ProtectedTagAccessDropdown({
      $dropdown: $allowedToCreateDropdown,
      accessLevelsData: gon.create_access_levels,
      onSelect: this.onSelectCallback,
      accessLevel: ACCESS_LEVELS.CREATE,
    });

    // Protected tag dropdown
    this.createItemDropdown = new CreateItemDropdown({
      $dropdown: this.$form.find('.js-protected-tag-select'),
      defaultToggleLabel: 'Protected Tag',
      fieldName: 'protected_tag[name]',
      onSelect: this.onSelectCallback,
      getData: ProtectedTagCreate.getProtectedTags,
    });
  }

  // Enable submit button after selecting an option
  onSelect() {
    const $allowedToCreate = this[`${ACCESS_LEVELS.CREATE}_dropdown`].getSelectedItems();
    const toggle = !(this.$form.find('input[name="protected_tag[name]"]').val() && $allowedToCreate.length);

    this.$form.find('input[type="submit"]').attr('disabled', toggle);
  }

  static getProtectedTags(term, callback) {
    callback(gon.open_tags);
  }

  getFormData() {
    const formData = {
      authenticity_token: this.$form.find('input[name="authenticity_token"]').val(),
      protected_tag: {
        name: this.$form.find('input[name="protected_tag[name]"]').val(),
      },
    };

    Object.keys(ACCESS_LEVELS).forEach((level) => {
      const accessLevel = ACCESS_LEVELS[level];
      const selectedItems = this[`${ACCESS_LEVELS.CREATE}_dropdown`].getSelectedItems();
      const levelAttributes = [];

      selectedItems.forEach((item) => {
        if (item.type === LEVEL_TYPES.USER) {
          levelAttributes.push({
            user_id: item.user_id,
          });
        } else if (item.type === LEVEL_TYPES.ROLE) {
          levelAttributes.push({
            access_level: item.access_level,
          });
        } else if (item.type === LEVEL_TYPES.GROUP) {
          levelAttributes.push({
            group_id: item.group_id,
          });
        }
      });

      formData.protected_tag[`${accessLevel}_attributes`] = levelAttributes;
    });

    return formData;
  }

  onFormSubmit(e) {
    e.preventDefault();

    $.ajax({
      url: this.$form.attr('action'),
      method: this.$form.attr('method'),
      data: this.getFormData(),
    })
    .success(() => {
      location.reload();
    })
    .fail(() => new Flash('Failed to protect the tag'));
  }
}
