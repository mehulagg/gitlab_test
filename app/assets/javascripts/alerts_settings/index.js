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

  const genericActivated = parseBoolean(activatedStr);
  const prometheusIsActivated = parseBoolean(prometheusActivated);
  const opsgenieMvcActivated = parseBoolean(opsgenieMvcEnabled);
  const opsgenieMvcIsAvailable = parseBoolean(opsgenieMvcAvailable);

  const props = {
    prometheus: {
      activated: prometheusIsActivated,
      prometheusUrl,
      prometheusAuthorizationKey,
      prometheusFormPath,
      prometheusResetKeyPath,
      prometheusApiUrl,
    },
    generic: {
      alertsSetupUrl,
      alertsUsageUrl,
      activated: genericActivated,
      formPath,
      initialAuthorizationKey: authorizationKey,
      url,
    },
  };

  if (opsgenieMvcIsAvailable) {
    props.opsgenie = {
      formPath: opsgenieMvcFormPath,
      activated: opsgenieMvcActivated,
      opsgenieMvcTargetUrl,
      opsgenieMvcIsAvailable,
    };
  } else {
    props.opsgenie = { opsgenieMvcIsAvailable };
  }

  return new Vue({
    el,
    render(createElement) {
      return createElement(AlertSettingsForm, {
        props,
      });
    },
  });
};
