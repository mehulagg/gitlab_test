import _ from 'underscore';
import Flash from '../flash';
import AUTH_METHOD from './constants';
import { backOff } from '../lib/utils/common_utils';

export default class MirrorPull {
  constructor(formSelector) {
    this.backOffRequestCounter = 0;

    this.$form = $(formSelector);

    this.$repositoryUrl = this.$form.find('.js-repo-url');

    this.$sectionSSHHostKeys = this.$form.find('.js-ssh-host-keys-section');
    this.$hostKeysInformation = this.$form.find('.js-fingerprint-ssh-info');
    this.$btnDetectHostKeys = this.$form.find('.js-detect-host-keys');
    this.$btnSSHHostsShowAdvanced = this.$form.find('.btn-show-advanced');
    this.$dropdownAuthType = this.$form.find('.js-pull-mirror-auth-type');

    this.$wellAuthTypeChanging = this.$form.find('.js-well-changing-auth');
    this.$wellPasswordAuth = this.$form.find('.js-well-password-auth');
    this.$wellSSHAuth = this.$form.find('.js-well-ssh-auth');
    this.$sshPublicKeyWrap = this.$form.find('.js-ssh-public-key-wrap');
  }

  init() {
    this.toggleAuthWell(this.$dropdownAuthType.val());

    this.$repositoryUrl.on('keyup', e => this.handleRepositoryUrlInput(e));
    this.$form.find('.js-known-hosts').on('keyup', e => this.handleSSHKnownHostsInput(e));
    this.$dropdownAuthType.on('change', e => this.handleAuthTypeChange(e));
    this.$btnDetectHostKeys.on('click', e => this.handleDetectHostKeys(e));
    this.$btnSSHHostsShowAdvanced.on('click', e => this.handleSSHHostsAdvanced(e));
  }

  /**
   * Method to monitor Git Repository URL input
   */
  handleRepositoryUrlInput() {
    const protocol = this.$repositoryUrl.val().split('://')[0];
    const protRegEx = /http|git/;

    // Validate URL and verify if it consists only supported protocols
    if (this.$form.get(0).checkValidity()) {
      // Hide/Show SSH Host keys section only for SSH URLs
      this.$sectionSSHHostKeys.toggleClass('hidden', protocol !== 'ssh');
      this.$btnDetectHostKeys.enable();

      // Verify if URL is http, https or git and hide/show Auth type dropdown
      // as we don't support auth type SSH for non-SSH URLs
      this.$dropdownAuthType.toggleClass('hidden', protRegEx.test(protocol));
    }
  }

  /**
   * Click event handler to detect SSH Host key and fingerprints from
   * provided Git Repository URL.
   */
  handleDetectHostKeys() {
    const projectMirrorSSHEndpoint = this.$form.data('project-mirror-endpoint');
    const repositoryUrl = this.$repositoryUrl.val();
    const $btnLoadSpinner = this.$btnDetectHostKeys.find('.detect-host-keys-load-spinner');

    // Disable button while we make request
    this.$btnDetectHostKeys.disable();
    $btnLoadSpinner.removeClass('hidden');

    // Make backOff polling to get data
    backOff((next, stop) => {
      $.getJSON(`${projectMirrorSSHEndpoint}?ssh_url=${repositoryUrl}`)
        .done((res, statusText, header) => {
          if (header.status === 204) {
            this.backOffRequestCounter = this.backOffRequestCounter += 1;
            if (this.backOffRequestCounter < 3) {
              next();
            } else {
              stop(res);
            }
          } else {
            stop(res);
          }
        })
        .fail(stop);
    })
    .then((res) => {
      $btnLoadSpinner.addClass('hidden');
      // Once data is received, we show verification info along with Host keys and fingerprints
      this.$hostKeysInformation.find('.js-fingerprint-verification').toggleClass('hidden', res.changes_project_import_data);
      if (res.known_hosts && res.fingerprints) {
        this.showSSHInformation(res);
      }
    })
    .catch((res) => {
      // Show failure message when there's an error and re-enable Detect host keys button
      const failureMessage = res.responseJSON ? res.responseJSON.message : 'Something went wrong on our end.';
      Flash(failureMessage); // eslint-disable-line
      $btnLoadSpinner.addClass('hidden');
      this.$btnDetectHostKeys.enable();
    });
  }

  /**
   * Method to monitor known hosts textarea input
   */
  handleSSHKnownHostsInput() {
    // Strike-out fingerprints and remove verification info if `known hosts` value is altered
    this.$hostKeysInformation.find('.js-fingerprints-list').addClass('invalidate');
    this.$hostKeysInformation.find('.js-fingerprint-verification').addClass('hidden');
  }

  /**
   * Click event handler for `Show advanced` button under SSH Host keys section
   */
  handleSSHHostsAdvanced() {
    const $knownHost = this.$sectionSSHHostKeys.find('.js-ssh-known-hosts');

    $knownHost.toggleClass('hidden');
    this.$btnSSHHostsShowAdvanced.toggleClass('show-advanced', $knownHost.hasClass('hidden'));
  }

  /**
   * Authentication method dropdown change event listener
   */
  handleAuthTypeChange() {
    const projectMirrorAuthTypeEndpoint = `${this.$form.attr('action')}.json`;
    const $sshPublicKey = this.$sshPublicKeyWrap.find('.ssh-public-key');
    const selectedAuthType = this.$dropdownAuthType.val();

    // Construct request body
    const authTypeData = {
      project: {
        import_data_attributes: {
          regenerate_ssh_private_key: true,
        },
      },
    };

    // Show load spinner and hide other containers
    this.$wellAuthTypeChanging.removeClass('hidden');
    this.$wellPasswordAuth.addClass('hidden');
    this.$wellSSHAuth.addClass('hidden');

    // This request should happen only if selected Auth type was SSH
    // and SSH Public key was not present on page load
    if (selectedAuthType === AUTH_METHOD.SSH &&
        !$sshPublicKey.text().trim()) {
      this.$dropdownAuthType.disable();
      $.ajax({
        type: 'PUT',
        url: projectMirrorAuthTypeEndpoint,
        contentType: 'application/json; charset=utf-8',
        data: JSON.stringify(authTypeData),
      })
      .done((res) => {
        // Show SSH public key container and fill in public key
        this.toggleAuthWell(selectedAuthType);
        this.toggleSSHAuthWellMessage(true);
        this.setSSHPublicKey(res.import_data_attributes.ssh_public_key);
      })
      .fail(() => {
        Flash('Something went wrong on our end.');
      })
      .always(() => {
        this.$wellAuthTypeChanging.addClass('hidden');
        this.$dropdownAuthType.enable();
      });
    } else {
      this.$wellAuthTypeChanging.addClass('hidden');
      this.toggleAuthWell(selectedAuthType);
      this.$wellSSHAuth.find('.js-ssh-public-key-present').removeClass('hidden');
    }
  }

  /**
   * Method to parse SSH Host keys data and render it
   * under SSH host keys section
   */
  showSSHInformation(sshHostKeys) {
    const $fingerprintsList = this.$hostKeysInformation.find('.js-fingerprints-list');
    let fingerprints = '';
    sshHostKeys.fingerprints.forEach((fingerprint) => {
      const escFingerprints = _.escape(fingerprint.fingerprint);
      fingerprints += `<code>${escFingerprints}</code>`;
    });

    this.$hostKeysInformation.removeClass('hidden');
    $fingerprintsList.removeClass('invalidate');
    $fingerprintsList.html(fingerprints);
    this.$sectionSSHHostKeys.find('.js-known-hosts').val(sshHostKeys.known_hosts);
  }

  /**
   * Toggle Auth type information container based on provided `authType`
   */
  toggleAuthWell(authType) {
    this.$wellPasswordAuth.toggleClass('hidden', authType !== AUTH_METHOD.PASSWORD);
    this.$wellSSHAuth.toggleClass('hidden', authType !== AUTH_METHOD.SSH);
  }

  /**
   * Toggle SSH auth information message
   */
  toggleSSHAuthWellMessage(sshKeyPresent) {
    this.$sshPublicKeyWrap.toggleClass('hidden', !sshKeyPresent);
    this.$wellSSHAuth.find('.js-ssh-public-key-present').toggleClass('hidden', !sshKeyPresent);
    this.$wellSSHAuth.find('.js-btn-regenerate-ssh-key').toggleClass('hidden', !sshKeyPresent);
    this.$wellSSHAuth.find('.js-ssh-public-key-pending').toggleClass('hidden', sshKeyPresent);
  }

  /**
   * Sets SSH Public key to Clipboard button and shows it on UI.
   */
  setSSHPublicKey(sshPublicKey) {
    this.$sshPublicKeyWrap.find('.ssh-public-key').text(sshPublicKey);
    this.$sshPublicKeyWrap.find('.btn-copy-ssh-public-key').attr('data-clipboard-text', sshPublicKey);
  }
}
