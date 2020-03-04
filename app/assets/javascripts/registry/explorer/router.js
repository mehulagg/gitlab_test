import Vue from 'vue';
import VueRouter from 'vue-router';
import { s__ } from '~/locale';
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
        meta: {
          nameGenerator: () => s__('ContainerRegistry|Container Registry'),
          root: true,
        },
        beforeEnter: (to, from, next) => {
          store.dispatch('requestImagesList');
          next();
        },
      },
      {
        name: 'details',
        path: '/:id',
        component: Details,
        meta: {
          nameGenerator: state => {
            return state?.imageDetails?.path;
          },
        },
        beforeEnter: (to, from, next) => {
          store.dispatch('requestImageDetails', to.params.id);
          next();
        },
      },
    ],
  });

  return router;
}
