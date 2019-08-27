import { createLocalVue, shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import AppVue from 'ee/elasticsearch/components/app.vue';
import EsList from 'ee/elasticsearch/components/es_list.vue';
import EsEmptyState from 'ee/elasticsearch/components/es_empty_state.vue';
import createStore from 'ee/elasticsearch/store';
import Service from 'ee/elasticsearch/service/elasticsearch_service';

const store = createStore();
const localVue = createLocalVue();
const dummyIndex = {
  id: 42,
  shards: 3,
  replicas: 2,
  aws: true,
  friendly_name: 'Dummy Index',
  urls: 'http://localhost:9200',
  aws_region: 'foo-bar-region',
  aws_access_key: 'my-key',
  aws_secret_access_key: 'my-secret',
};

jest.mock('ee/elasticsearch/service/elasticsearch_service');

describe('ES Indices App view', () => {
  let wrapper;
  let mock;

  function createComponent(props = {}) {
    wrapper = shallowMount(AppVue, {
      localVue,
      store,
    });
    wrapper.vm.isLoading = false;
  }

  beforeEach(() => {
    Service.getApplicationSettings = jest.fn(() => Promise.resolve());
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  it('renders empty state in case there are no indices', () => {
    Service.getIndices = jest.fn(() => Promise.resolve());
    createComponent();
    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.find(EsEmptyState).exists()).toBe(true);
      expect(wrapper.find(EsList).exists()).toBe(false);
    });
  });

  it('renders indices list if at least one index exists', () => {
    Service.getIndices = jest.fn(() => Promise.resolve({ data: [dummyIndex] }));
    createComponent();
    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.find(EsEmptyState).exists()).toBe(false);
      expect(wrapper.find(EsList).exists()).toBe(true);
    });
  });
});
