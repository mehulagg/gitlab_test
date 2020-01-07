import Vue from 'vue';
import VueRouter from 'vue-router';
import List from './pages/list.vue';
import Details from './pages/details.vue';

Vue.use(VueRouter);

export default function createRouter(base, store) {
  const router = new VueRouter({
    base,
    mode: 'history',
    routes: [
      {
        name: 'list',
        path: '/',
        component: List,
        beforeEnter: (to, from, next) => {
          store.dispatch('requestImagesList');
          next();
        },
      },
      {
        name: 'details',
        path: '/:id',
        component: Details,
      },
    ],
  });

  return router;
}
