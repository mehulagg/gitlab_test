import _ from 'underscore';
import Vue from 'vue';
import { mountComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import app from '~/releases/components/app_index.vue';
import createStore from '~/releases/stores';
import listModule from '~/releases/stores/modules/list';
import api from '~/api';
import { resetStore } from '../stores/modules/list/helpers';
import {
  pageInfoHeadersWithoutPagination,
  pageInfoHeadersWithPagination,
  release,
  releases,
} from '../mock_data';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

describe('Releases App ', () => {
  const Component = Vue.extend(app);
  let store;
  let vm;
  let releasesPagination;

  const props = {
    projectId: 'gitlab-ce',
    documentationPath: 'help/releases',
    illustrationPath: 'illustration/path',
  };

  beforeEach(() => {
    store = createStore({ modules: { list: listModule } });
    releasesPagination = _.range(21).map(index => ({
      ...convertObjectPropsToCamelCase(release, { deep: true }),
      tagName: `${index}.00`,
    }));
  });

  afterEach(() => {
    resetStore(store);
    vm.$destroy();
  });

  describe('while loading', () => {
    beforeEach(() => {
      spyOn(api, 'releases').and.returnValue(Promise.resolve({ data: [], headers: {} }));
      vm = mountComponentWithStore(Component, { props, store });
    });

    it('renders loading icon', done => {
      expect(vm.$el.querySelector('.js-loading')).not.toBeNull();
      expect(vm.$el.querySelector('.js-empty-state')).toBeNull();
      expect(vm.$el.querySelector('.js-success-state')).toBeNull();
      expect(vm.$el.querySelector('.gl-pagination')).toBeNull();

      setTimeout(() => {
        done();
      }, 0);
    });
  });

  describe('with successful request', () => {
    beforeEach(() => {
      spyOn(api, 'releases').and.returnValue(
        Promise.resolve({ data: releases, headers: pageInfoHeadersWithoutPagination }),
      );
      vm = mountComponentWithStore(Component, { props, store });
    });

    it('renders success state', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.js-loading')).toBeNull();
        expect(vm.$el.querySelector('.js-empty-state')).toBeNull();
        expect(vm.$el.querySelector('.js-success-state')).not.toBeNull();
        expect(vm.$el.querySelector('.gl-pagination')).toBeNull();

        done();
      }, 0);
    });
  });

  describe('with successful request and pagination', () => {
    beforeEach(() => {
      spyOn(api, 'releases').and.returnValue(
        Promise.resolve({ data: releasesPagination, headers: pageInfoHeadersWithPagination }),
      );
      vm = mountComponentWithStore(Component, { props, store });
    });

    it('renders success state', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.js-loading')).toBeNull();
        expect(vm.$el.querySelector('.js-empty-state')).toBeNull();
        expect(vm.$el.querySelector('.js-success-state')).not.toBeNull();
        expect(vm.$el.querySelector('.gl-pagination')).not.toBeNull();

        done();
      }, 0);
    });
  });

  describe('with empty request', () => {
    beforeEach(() => {
      spyOn(api, 'releases').and.returnValue(Promise.resolve({ data: [], headers: {} }));
      vm = mountComponentWithStore(Component, { props, store });
    });

    it('renders empty state', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.js-loading')).toBeNull();
        expect(vm.$el.querySelector('.js-empty-state')).not.toBeNull();
        expect(vm.$el.querySelector('.js-success-state')).toBeNull();
        expect(vm.$el.querySelector('.gl-pagination')).toBeNull();

        done();
      }, 0);
    });
  });

  describe('"New release" button', () => {
    const factory = (additionalProps = {}) => {
      vm = mountComponentWithStore(Component, {
        props: {
          ...props,
          ...additionalProps,
        },
        store,
      });
    };

    const findNewReleaseButton = () => vm.$el.querySelector('.js-new-release-btn');

    describe('when the user is allowed to create a new Release', () => {
      const newReleasePath = 'path/to/new/release';

      beforeEach(() => {
        factory({ newReleasePath });
      });

      it('renders the "New release" button', () => {
        expect(findNewReleaseButton()).not.toBeNull();
      });

      it('renders the "New release" button with the correct href', () => {
        expect(findNewReleaseButton().getAttribute('href')).toBe(newReleasePath);
      });
    });

    describe('when the user is not allowed to create a new Release', () => {
      beforeEach(factory);

      it('does not render the "New release" button', () => {
        expect(findNewReleaseButton()).toBeNull();
      });
    });
  });
});
