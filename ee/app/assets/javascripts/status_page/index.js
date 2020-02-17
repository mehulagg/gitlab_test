import Vue from 'vue';
import router from './router';
import IndexPage from './pages/index.vue'

const app = new Vue({
  router: router(),
  components: {
    IndexPage,
  },
  render(createElement) {
    return createElement('index-page');
  },
}).$mount('#app');