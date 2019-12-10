<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';
import Flash from '~/flash';
import { loadPaymentFormParams } from '../../../stores/actions';
import { ZUORA_SCRIPT_URL } from '../../../stores/constants';

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    active: {
      type: Boolean,
      required: true,
    },
    success: {
      type: Function,
      required: true,
    },
  },
  data() {
    return {
      loading: true,
      overrideParams: {
        style: 'inline',
        submitEnabled: 'true',
        retainValues: 'true',
      },
    };
  },
  mounted() {
    this.loadScript();
  },
  methods: {
    loadScript() {
      if (typeof window.Z === 'undefined') {
        const zuoraScript = document.createElement('script');
        zuoraScript.type = 'text/javascript';
        zuoraScript.async = true;
        zuoraScript.onload = this.renderIframe;
        zuoraScript.src = ZUORA_SCRIPT_URL;
        document.head.appendChild(zuoraScript);
      } else {
        this.renderIframe();
      }
    },
    renderIframe() {
      loadPaymentFormParams()
        .then(data => {
          if (data.errors) {
            Flash(
              sprintf(this.$options.i18n.fetchingParametersFailedMessage, {
                message: data.errors,
              }),
            );
          } else {
            const params = { ...data, ...this.overrideParams };
            window.Z.runAfterRender(this.iframeLoaded);
            window.Z.render(params, {}, this.callback);
          }
        })
        .catch(() => {
          Flash(this.$options.i18n.creditCardFormLoadingFailedMessage);
        });
    },
    iframeLoaded() {
      this.toggleLoading();
    },
    callback(response) {
      if (response.success) {
        this.toggleLoading();
        this.success(response.refId, this.toggleLoading);
      } else {
        Flash(
          sprintf(this.$options.i18n.submitFormFailedMessage, {
            code: response.errorCode,
            message: response.errorMessage,
          }),
        );
      }
    },
    toggleLoading() {
      this.loading = !this.loading;
    },
  },
  i18n: {
    fetchingParametersFailedMessage: s__('Checkout|Credit card form failed to load: %{message}'),
    creditCardFormLoadingFailedMessage: s__(
      'Checkout|Credit card form failed to load. Please try again.',
    ),
    submitFormFailedMessage: s__(
      'Checkout|Submitting the credit card form failed with code %{code}: %{message}',
    ),
  },
};
</script>
<template>
  <div>
    <gl-loading-icon v-if="loading" size="lg" />
    <div v-show="active && !loading" id="zuora_payment"></div>
  </div>
</template>
