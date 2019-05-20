import Vue from 'vue';
import { mount, shallowMount } from '@vue/test-utils';
import PaginatedList from '~/vue_shared/components/paginated_list.vue';

describe('Resizable Chart Container', () => {
  let template;

  beforeAll(() => {
    template = `
      <div class="slot" slot-scope="{ listItem }">
        <span class="item">Item Name: {{listItem.id}}</span>
      </div>
    `;
  });

  describe('Searchless states', () => {
    let wrapper;

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders the list in an empty state, when no items are provided', () => {
      wrapper = shallowMount(PaginatedList, {
        scopedSlots: {
          default: template,
        },
        propsData: {
          list: [],
        },
      });
      expect(wrapper.findAll('.item').length).toEqual(0);
      expect(wrapper.findAll('.empty-message').length).toEqual(1);
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders the list in an empty state with a custom empty message, when one is provided', () => {
      const msg = 'List is passed in empty';

      wrapper = shallowMount(PaginatedList, {
        scopedSlots: {
          default: template,
        },
        propsData: {
          list: [],
          emptyMessage: msg,
        },
      });
      expect(wrapper.findAll('.item').length).toEqual(0);
      expect(wrapper.find('.empty-message').text()).toEqual(msg);
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders the list with nested items, when an array of items is provided', () => {
      wrapper = shallowMount(PaginatedList, {
        propsData: {
          list: [{ id: 'foo' }, { id: 'bar' }],
        },
        scopedSlots: {
          default: template,
        },
      });
      expect(wrapper.findAll('.item').length).toEqual(2);
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('Search states', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = shallowMount(PaginatedList, {
        propsData: {
          list: [{ id: 'foo' }, { id: 'bar' }, { id: 'baz' }],
        },
        scopedSlots: {
          default: template,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders the list flitered by search results', done => {
      wrapper.vm.queryStr = 'ba';

      return Vue.nextTick()
        .then(() => {
          expect(wrapper.findAll('.item').length).toEqual(2);
          expect(wrapper.element).toMatchSnapshot();
          done();
        })
        .catch(done.fail);
    });

    it('renders the default empty search message when there are no search results', done => {
      wrapper.vm.queryStr = 'qux';

      return Vue.nextTick()
        .then(() => {
          expect(wrapper.findAll('.item').length).toEqual(0);
          expect(wrapper.findAll('.empty-search').length).toEqual(1);
          expect(wrapper.element).toMatchSnapshot();
          done();
        })
        .catch(done.fail);
    });

    it('renders the custom empty search message when there are no search results', done => {
      const msg = 'Custom empty message';

      wrapper = shallowMount(PaginatedList, {
        propsData: {
          list: [{ id: 'foo' }, { id: 'bar' }, { id: 'baz' }],
          emptySearchMessage: msg,
        },
        scopedSlots: {
          default: template,
        },
      });

      wrapper.vm.queryStr = 'qux';

      return Vue.nextTick()
        .then(() => {
          expect(wrapper.findAll('.item').length).toEqual(0);
          expect(wrapper.find('.empty-search').text()).toEqual(msg);
          expect(wrapper.element).toMatchSnapshot();
          done();
        })
        .catch(done.fail);
    });
  });

  describe('Pagination', () => {
    let wrapper;

    const list = [
      { id: 'foo' },
      { id: 'bar' },
      { id: 'baz' },
      { id: 'qux' },
      { id: 'quux' },
      { id: 'corge' },
      { id: 'grault' },
      { id: 'garply' },
      { id: 'waldo' },
      { id: 'fred' },
      { id: 'xyzzy' },
      { id: 'plugh' },
      { id: 'thud' },
    ];

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders 10 items for a default page size of 10, 13 total and renders pagination', () => {
      wrapper = mount(PaginatedList, {
        propsData: {
          list,
        },
        scopedSlots: {
          default: template,
        },
      });

      expect(wrapper.findAll('.item').length).toEqual(10);
      expect(wrapper.findAll('.gl-pagination').length).toEqual(1);
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders 13 items for a default page size of 20, 13 total items, and does not render pagination', () => {
      wrapper = mount(PaginatedList, {
        propsData: {
          list,
          perPage: 20,
        },
        scopedSlots: {
          default: template,
        },
      });

      expect(wrapper.findAll('.item').length).toEqual(13);
      expect(wrapper.findAll('.gl-pagination').length).toEqual(0);
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders 5 items on page 1 for a page size of 5, 13 total itmes and renders pagination', () => {
      wrapper = mount(PaginatedList, {
        propsData: {
          list,
          perPage: 5,
        },
        scopedSlots: {
          default: template,
        },
      });

      expect(wrapper.findAll('.item').length).toEqual(5);
      expect(wrapper.findAll('.gl-pagination').length).toEqual(1);
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders 3 items on page 2 with default page size of 10 and 13 total items', () => {
      wrapper = shallowMount(PaginatedList, {
        propsData: {
          list,
          page: 2,
        },
        scopedSlots: {
          default: template,
        },
      });

      expect(wrapper.findAll('.item').length).toEqual(3);
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders 1 item on page 7 with page size of 2 and 13 total items', () => {
      wrapper = shallowMount(PaginatedList, {
        propsData: {
          list,
          page: 7,
          perPage: 2,
        },
        scopedSlots: {
          default: template,
        },
      });

      expect(wrapper.findAll('.item').length).toEqual(1);
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('props', () => {
    let wrapper;

    afterEach(() => {
      wrapper.destroy();
    });

    describe('filterable', () => {
      it('has search enabled by default', () => {
        wrapper = mount(PaginatedList, {
          scopedSlots: {
            default: template,
          },
          propsData: {
            list: [],
          },
        });

        expect(wrapper.findAll('[aria-label="Search"]').length).toEqual(1);
      });

      it('has search disabled when filterable prop set to false', () => {
        wrapper = mount(PaginatedList, {
          scopedSlots: {
            default: template,
          },
          propsData: {
            list: [],
            filterable: false,
          },
        });

        expect(wrapper.findAll('[aria-label="Search"]').length).toEqual(0);
      });
    });

    describe('filterKey', () => {
      it('filters on default "id" key', done => {
        wrapper = shallowMount(PaginatedList, {
          scopedSlots: {
            default: template,
          },
          propsData: {
            list: [{ id: 'foo' }, { id: 'bar' }],
          },
        });

        wrapper.vm.queryStr = 'ba';

        return Vue.nextTick()
          .then(() => {
            expect(wrapper.findAll('.item').length).toEqual(1);
            expect(wrapper.element).toMatchSnapshot();
            done();
          })
          .catch(done.fail);
      });

      it('filters on provided "myKey" key', done => {
        wrapper = shallowMount(PaginatedList, {
          scopedSlots: {
            default: template,
          },
          propsData: {
            list: [{ myKey: 'foo' }, { myKey: 'bar' }],
            filterKey: 'myKey',
          },
        });

        wrapper.vm.queryStr = 'ba';

        return Vue.nextTick()
          .then(() => {
            expect(wrapper.findAll('.item').length).toEqual(1);
            expect(wrapper.element).toMatchSnapshot();
            done();
          })
          .catch(done.fail);
      });

      it('gracefully renders all items and disables filtering when provided an invalid filterKey', done => {
        wrapper = shallowMount(PaginatedList, {
          scopedSlots: {
            default: template,
          },
          propsData: {
            list: [{ myKey: 'foo' }, { myKey: 'bar' }],
            filterKey: 'nonMatchingKey',
          },
        });

        wrapper.vm.queryStr = 'ba';

        return Vue.nextTick()
          .then(() => {
            expect(wrapper.findAll('.item').length).toEqual(2);
            expect(wrapper.element).toMatchSnapshot();
            done();
          })
          .catch(done.fail);
      });
    });
  });
});
