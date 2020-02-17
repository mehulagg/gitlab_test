import Vue from 'vue';
import VueRouter from 'vue-router';
import IncidentListPage from './pages/list.vue';
import IncidentDetailsPage from './pages/details.vue';

Vue.use(VueRouter);

export default () => {
  const routes = [
    {
      path: '/',
      name: 'list',
      component: IncidentListPage,
    },
    {
      path: '/details/:id',
      name: 'details',
      component: IncidentDetailsPage,
    },
  ];
  const router = new VueRouter({
    mode: 'history',
    base: window.location.pathname,
    routes,
  });

  return router;
};
