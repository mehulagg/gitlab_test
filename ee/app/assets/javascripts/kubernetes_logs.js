import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import { getParameterValues } from '~/lib/utils/url_utility';
import { isScrolledToBottom, scrollDown, toggleDisableButton } from '~/lib/utils/scroll_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import LogOutputBehaviours from '~/lib/utils/logoutput_behaviours';
import createFlash from '~/flash';
import { sprintf, __, s__ } from '~/locale';
import _ from 'underscore';

export default class KubernetesPodLogs extends LogOutputBehaviours {
  constructor(container) {
    super();
    this.options = $(container).data();

    [this.podName] = getParameterValues('pod_name');
    this.podName = _.escape(this.podName);
    this.environmentName = this.options.environmentName;
    this.environmentsPath = this.options.environmentsPath;
    this.logsPath = this.options.logsPath;
    this.logsPage = this.options.logsPage;

    this.$window = $(window);
    this.$buildOutputContainer = $(container).find('.js-build-output');
    this.$refreshLogBtn = $(container).find('.js-refresh-log');
    this.$buildRefreshAnimation = $(container).find('.js-build-refresh');
    this.$podDropdown = $(container).find('.js-pod-dropdown');
    this.$envDropdown = $(container).find('.js-environment-dropdown');

    this.isLogComplete = false;

    this.scrollThrottled = _.throttle(this.toggleScroll.bind(this), 100);
    this.$window.off('scroll').on('scroll', () => {
      if (!isScrolledToBottom()) {
        this.toggleScrollAnimation(false);
      } else if (isScrolledToBottom() && !this.isLogComplete) {
        this.toggleScrollAnimation(true);
      }
      this.scrollThrottled();
    });

    this.$refreshLogBtn.off('click').on('click', this.getData.bind(this));
  }

  scrollToBottom() {
    scrollDown();
    this.toggleScroll();
  }

  scrollToTop() {
    $(document).scrollTop(0);
    this.toggleScroll();
  }

  getData() {
    this.scrollToTop();
    this.$buildOutputContainer.empty();
    this.$buildRefreshAnimation.show();
    toggleDisableButton(this.$refreshLogBtn, 'true');

    this.getEnvironments();
    this.getLogs();
  }

  getEnvironments() {
    return axios
      .get(this.environmentsPath)
      .then(res => {
        const { environments } = res.data;

        this.setupDropdown(
          this.$envDropdown,
          this.environmentName,
          environments.map(env => ({ name: env.name, value: env.id })),
          el => {
            const envId = el.currentTarget.value;
            const envRegexp = /environments\/[0-9]+/gi;
            const href = this.logsPage.replace(envRegexp, `environments/${envId}`);
            window.location.href = href;
          },
        );
      })
      .catch(() => createFlash(__('Something went wrong on our end')));
  }

  getLogs() {
    const { logsPath } = this.options;
    const params = {};

    if (this.podName) {
      params.pod_name = this.podName;
    }
    return axios
      .get(logsPath, {
        params,
      })
      .then(res => {
        const { logs, pods } = res.data;

        // Display pods dropdown
        this.podName = this.podName || pods[0];
        this.setupDropdown(
          this.$podDropdown,
          this.podName,
          pods.map(podName => ({ name: podName, value: podName })),
          el => {
            const selectedPodName = el.currentTarget.value;
            if (selectedPodName !== this.podName) {
              this.podName = selectedPodName;
              this.getData();
            }
          },
        );

        // Display logs
        const formattedLogs = logs.map(logEntry => `${_.escape(logEntry)} <br />`);
        this.$buildOutputContainer.append(formattedLogs);
        scrollDown();
        this.isLogComplete = true;
        toggleDisableButton(this.$refreshLogBtn, false);
      })
      .catch(err => {
        if (err.response && err.response.status === httpStatusCodes.NOT_FOUND) {
          createFlash(
            s__(
              'Environments|No pods available for this environment. Please select another environment',
            ),
            'notice',
          );
        } else {
          let message = '';
          if (err.response) {
            message = sprintf(`Error: %{message}`, { message: err.response.data.message });
          }
          createFlash(
            sprintf(__(`Something went wrong on our end. %{message}`), {
              message,
            }),
          );
        }
      })
      .finally(() => {
        this.$buildRefreshAnimation.hide();
      });
  }

  setupDropdown($dropdown, activeOption, options, onSelect) {
    const $dropdownMenu = $dropdown.find('.dropdown-menu');

    $dropdown
      .find('.dropdown-menu-toggle')
      .html(
        `<span class="dropdown-toggle-text text-truncate">${activeOption}</span><i class="fa fa-chevron-down"></i>`,
      );

    $dropdownMenu.off('click');
    $dropdownMenu.empty();

    options.forEach(option => {
      $dropdownMenu.append(`
        <button class='dropdown-item' value='${option.value}'>
          ${_.escape(option.name)}
        </button>
      `);
    });

    $dropdownMenu.find('button').on('click', onSelect.bind(this));
  }
}
