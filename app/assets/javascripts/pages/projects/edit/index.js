import { PROJECT_BADGE } from '~/badges/constants';
import initSettingsPanels from '~/settings_panels';
import setupProjectEdit from '~/project_edit';
import initConfirmDangerModal from '~/confirm_danger_modal';
import mountBadgeSettings from '~/pages/shared/mount_badge_settings';
import dirtySubmitFactory from '~/dirty_submit/dirty_submit_factory';
import fileUpload from '~/lib/utils/file_upload';
import initProjectLoadingSpinner from '../shared/save_project_loader';
import initProjectPermissionsSettings from '../shared/permissions';

document.addEventListener('DOMContentLoaded', () => {
  fileUpload('.js-choose-project-avatar-button', '.js-project-avatar-input');
  initConfirmDangerModal();
  initSettingsPanels();
  mountBadgeSettings(PROJECT_BADGE);

  initProjectLoadingSpinner();
  initProjectPermissionsSettings();
  setupProjectEdit();

  dirtySubmitFactory(
    document.querySelectorAll(
      '.js-general-settings-form, .js-mr-settings-form, .js-add-approver-form',
    ),
  );
});
