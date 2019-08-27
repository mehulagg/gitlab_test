import Vue from 'vue';
import VueRouter from 'vue-router';
import IndicesApp from './components/app.vue';
import NewIndex from './components/es_new_index.vue';

Vue.use(VueRouter);

export default function createRouter(base) {
  return new VueRouter({
    mode: 'history',
    base,
    routes: [
      {
        path: '/admin/elasticsearch',
        name: 'root',
        component: IndicesApp,
      },
      {
        path: `/admin/elasticsearch/new`,
        name: 'newIndexPath',
        component: NewIndex,
      },
      {
        path: `/admin/elasticsearch/edit/:indexid`,
        name: 'editIndexPath',
        component: NewIndex,
        props: true,
      },
    ],
  });
}
