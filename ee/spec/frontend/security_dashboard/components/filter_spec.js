import Vue from 'vue';
import { mount } from '@vue/test-utils';
import FilterComponent from 'ee/security_dashboard/components/filter.vue';
import createStore from 'ee/security_dashboard/store';

describe('Filter component', () => {
  let vm;
  let props;
  let store;
  let wrapper;

  function setProjectsCount(count) {
    const projects = new Array(count).fill(null).map((_, i) => ({
      name: i.toString(),
      id: i.toString(),
    }));

    store.dispatch('filters/setFilterOptions', {
      filterId: 'project_id',
      options: projects,
    });
  }

  function createComponent({ props: propsData, store: initialStore }) {
    return mount(FilterComponent, {
      sync: false,
      attachToDocument: true,
      store: initialStore,
      propsData,
    });
  }

  const findSearchInput = () => wrapper.find('input');
  const findDropdownItem = () => wrapper.findAll('.dropdown-item');
  const findCheckedDropdownOptions = () => wrapper.findAll('.dropdown-item .js-check');
  const findOptionName = () => wrapper.findAll('.js-name');
  const findDropdownToggle = () => wrapper.find('.dropdown-toggle');

  function isDropdownOpen() {
    console.log('wrapper::html', wrapper.html());
    const toggleButton = findDropdownToggle();
    console.log('isDropdown', toggleButton.attrs('aria-expanded'));
    return toggleButton.attrs('aria-expanded') === 'true';
  }

  beforeEach(() => {
    store = createStore();
    wrapper = null;
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe.only('severity', () => {
    beforeEach(() => {
      props = { filterId: 'severity' };
      wrapper = createComponent({ store, props });
      return Vue.nextTick();
    });

    it('should display all 8 severity options', () => {
      expect(findDropdownItem().length).toEqual(8);
    });

    it('should display a check next to only the selected item', () => {
      expect(findCheckedDropdownOptions().length).toEqual(1);
    });

    it('should display "Severity" as the option name', () => {
      expect(
        findOptionName()
          .at(0)
          .text(),
      ).toContain('Severity');
    });

    it('should not have a search box', () => {
      expect(findSearchInput()).not.toEqual(jasmine.any(HTMLElement));
    });

    it('should not be open', () => {
      expect(isDropdownOpen()).toBe(false);
    });

    describe('when the dropdown is open', () => {
      beforeEach(() => {
        findDropdownToggle().trigger('click');
        // vm.$on('bv::dropdown::shown', () => {
        //   done();
        // });

        return Vue.nextTick();
      });

      it('should keep the menu open after clicking on an item', done => {
        expect(isDropdownOpen()).toBe(true);
        findDropdownItem()
          .at(0)
          .trigger('click');

        Vue.nextTick(() => {
          expect(isDropdownOpen()).toBe(true);
          done();
        });
      });

      it('should close the menu when the close button is clicked', done => {
        expect(isDropdownOpen()).toBe(true);
        vm.$refs.close.click();
        vm.$nextTick(() => {
          expect(isDropdownOpen()).toBe(false);
          done();
        });
      });
    });
  });

  describe.only('Project', () => {
    describe('when there are lots of projects', () => {
      const lots = 30;
      beforeEach(done => {
        props = { filterId: 'project_id', dashboardDocumentation: '' };
        wrapper = createComponent({ store, props });
        setProjectsCount(lots);
        Vue.nextTick(done);
      });

      it('should display a search box', () => {
        expect(findSearchInput().exists()).toEqual(true);
      });

      it(`should show all projects`, () => {
        expect(findDropdownItem().length).toBe(lots);
      });

      it('should show only matching projects when a search term is entered', done => {
        const input = findSearchInput();
        input.value = '0';
        input.dispatchEvent(new Event('input'));
        vm.$nextTick(() => {
          expect(vm.$el.querySelectorAll('.dropdown-item').length).toBe(3);
          done();
        });
      });
    });
  });
});
