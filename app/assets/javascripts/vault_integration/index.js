import Vue from 'vue';
import store from './store';
import VaultIntegration from './components/vault_integration.vue';

export default () => {
  const el = document.querySelector('.js-vault-integration');
  return new Vue({
    el,
    store: store(el.dataset),
    render(createElement) {
      return createElement(VaultIntegration);
    },
  });
};
