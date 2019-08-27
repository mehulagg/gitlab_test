import { createLocalVue, mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import NewIndexView from 'ee/elasticsearch/components/es_new_index.vue';
import createStore from 'ee/elasticsearch/store';
import Service from 'ee/elasticsearch/service/elasticsearch_service';

import { TEST_HOST } from 'helpers/test_constants';

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

describe('ES New Index view', () => {
  let vm;
  let mock;
  const awsFields = ['aws_region', 'aws_access_key', 'aws_secret_access_key'];
  const btnSelector = '.form-actions button[type="submit"]';

  function createComponent(props = {}) {
    const wrapper = mount(localVue.extend(NewIndexView), { localVue, store, propsData: props });
    vm = wrapper.vm;
  }

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    vm.$destroy();
  });

  it('by default renders AWS settings as collapsed', () => {
    createComponent();
    expect(vm.$el.querySelector('input#aws').checked).toBe(false);
    awsFields.forEach(field => {
      expect(vm.$el.querySelector(`#${field}`)).toBeNull();
    });
  });

  it('expands AWS settings when aws prop is `true`', () => {
    createComponent({ aws: true });
    vm.$nextTick()
      .then(() => {
        expect(vm.$el.querySelector('input#aws').checked).toBe(true);
        awsFields.forEach(field => {
          expect(vm.$el.querySelector(`#${field}`)).not.toBeNull();
        });
      })
      .catch(() => {});
  });

  it('does not submit the form without a name', () => {
    dummyIndex.friendly_name = '';
    createComponent({ ...dummyIndex });

    const spy = jest.spyOn(vm, 'createIndex');
    vm.$nextTick()
      .then(() => {
        const btn = vm.$el.querySelector(btnSelector);
        btn.click();
        expect(spy).not.toHaveBeenCalled();
      })
      .catch(() => {});
  });

  it('does not submit the form without a URLs', () => {
    dummyIndex.urls = '';
    createComponent({ ...dummyIndex });

    const spy = jest.spyOn(vm, 'createIndex');
    vm.$nextTick()
      .then(() => {
        const btn = vm.$el.querySelector(btnSelector);
        btn.click();
        expect(spy).not.toHaveBeenCalled();
      })
      .catch(() => {});
  });

  describe('New Index', () => {
    it('renders correct view title', () => {
      createComponent();
      expect(vm.$el.querySelector('h4').innerText.trim()).toContain('New GitLab index');
    });

    it('renders actionable button', () => {
      createComponent();
      expect(vm.$el.querySelector(btnSelector).innerText.trim()).toContain('Create GitLab index');
    });
    it('sends data to correct API endpoint when the form is submitted', () => {
      createComponent({ ...dummyIndex });

      const spy = jest.spyOn(vm, 'createIndex');
      vm.$nextTick()
        .then(() => {
          const btn = vm.$el.querySelector(btnSelector);
          btn.click();
          expect(spy).toHaveBeenCalled();
          expect(Service.createNewIndex).toHaveBeenCalledWith({ ...dummyIndex });
        })
        .catch(() => {});
    });
  });

  describe('Edit Index', () => {
    describe('pre-fetched index in the store', () => {
      beforeEach(() => {
        Object.assign(store.state, {
          indices: [dummyIndex],
        });
        createComponent({ indexid: '42' });
      });

      it('renders correct view title', () => {
        expect(vm.$el.querySelector('h4').innerText.trim()).toContain('Edit GitLab index');
      });

      it('renders actionable button', () => {
        expect(vm.$el.querySelector(btnSelector).innerText.trim()).toContain('Save changes');
      });

      it('sends data to correct API endpoint when the form is submitted', () => {
        const spy = jest.spyOn(vm, 'createIndex');
        vm.$nextTick()
          .then(() => {
            const btn = vm.$el.querySelector(btnSelector);
            btn.click();
            expect(spy).toHaveBeenCalled();
            expect(Service.createNewIndex).not.toHaveBeenCalled();
            expect(Service.updateIndex).toHaveBeenCalledWith('42', { ...dummyIndex });
          })
          .catch(() => {});
      });
    });
    describe('not pre-fetched index', () => {
      beforeEach(() => {
        Service.getIndex = jest.fn(() => Promise.resolve({ data: dummyIndex }));
        createComponent({ indexid: '42' });
      });
      it('fetches index from the server', () => {
        vm.$nextTick()
          .then(() => {
            expect(Service.getIndex).toHaveBeenCalledWith('42');
          })
          .catch(() => {});
      });
    });
  });
});
