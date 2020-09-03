import Vue from 'vue';
import App from './components/app.vue';

function onLoaded() {
  const el = document.querySelector('.js-jira-connect-app');

  return new Vue({
    el,
    render(createElement) {
      return createElement(App, {
        props: {
          subscriptionPath: el.dataset.subscriptionPath,
          subscriptions: JSON.parse(el.dataset.subscriptions),
          namespaces: JSON.parse(el.dataset.namespaces),
        },
      });
    },
  });
}

document.addEventListener('DOMContentLoaded', onLoaded);
