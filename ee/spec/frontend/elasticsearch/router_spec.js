import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { mount, createLocalVue } from '@vue/test-utils';
import VueRouter from 'vue-router';
import App from 'ee/elasticsearch/components/index.vue';
import IndicesApp from 'ee/elasticsearch/components/app.vue';
import NewIndex from 'ee/elasticsearch/components/es_new_index.vue';
import createRouter from 'ee/elasticsearch/router';

import createStore from 'ee/elasticsearch/store';

const localVue = createLocalVue();
const router = createRouter();
const store = createStore();

localVue.use(VueRouter);

describe('Elasticsearch router', () => {
  let wrapper;
  let mock;

  function factory() {
    mock = new MockAdapter(axios);
    wrapper = mount(App, {
      localVue,
      store,
      router,
    });
  }

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  it('pushes New Index component', () => {
    router.push({ name: 'newIndexPath' });

    expect(wrapper.find(NewIndex).exists()).toBe(true);
  });

  it('pushes root component', () => {
    router.push({ name: 'root' });

    expect(wrapper.find(IndicesApp).exists()).toBe(true);
  });

  it('when editing, pushes New Index component as well', () => {
    router.push({ name: 'editIndexPath', params: { indexid: '1' } });

    expect(wrapper.find(NewIndex).exists()).toBe(true);
  });
});
