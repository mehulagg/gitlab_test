import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import AlertSettingsForm from './components/alerts_settings_form.vue';

export default el => {
  if (!el) {
    return null;
  }

  const {
    prometheusActivated,
    prometheusUrl,
    prometheusAuthorizationKey,
    prometheusFormPath,
    prometheusResetKeyPath,
    prometheusApiUrl,
    activated: activatedStr,
    alertsSetupUrl,
    alertsUsageUrl,
    formPath,
    authorizationKey,
    url,
    opsgenieMvcAvailable,
    opsgenieMvcFormPath,
    opsgenieMvcEnabled,
    opsgenieMvcTargetUrl,
  } = el.dataset;

  const activated = parseBoolean(activatedStr);
  const prometheusIsActivated = parseBoolean(prometheusActivated);
  const opsgenieMvcActivated = parseBoolean(opsgenieMvcEnabled);
  const opsgenieMvcIsAvailable = parseBoolean(opsgenieMvcAvailable);

  const props = {
    prometheus: {
      prometheusIsActivated,
      prometheusUrl,
      prometheusAuthorizationKey,
      prometheusFormPath,
      prometheusResetKeyPath,
      prometheusApiUrl,
    },
    generic: {
      alertsSetupUrl,
      alertsUsageUrl,
      initialActivated: activated,
      formPath,
      initialAuthorizationKey: authorizationKey,
      url,
    },
    opsgenie: opsgenieMvcIsAvailable
      ? {
          formPath: opsgenieMvcFormPath,
          opsgenieMvcActivated,
          opsgenieMvcTargetUrl,
          opsgenieMvcIsAvailable,
        }
      : {
          opsgenieMvcIsAvailable,
        },
  };

  return new Vue({
    el,
    render(createElement) {
      return createElement(AlertSettingsForm, {
        props,
      });
    },
  });
};
