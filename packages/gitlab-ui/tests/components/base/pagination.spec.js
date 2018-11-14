import { shallowMount } from '@vue/test-utils';
import BPagination from 'bootstrap-vue/es/components/pagination/pagination';
import Pagination from '../../../components/base/pagination/pagination.vue';
import { breakpoints } from '../../../helpers/breakpoints';

describe('pagination component', () => {
  const change = () => {};
  const propsData = {
    change,
    page: 3,
    perPage: 5,
    totalItems: 30,
  };
  const mountWithOptions = shallowMount.bind(null, Pagination);

  it('should wrap BPagination', () => {
    const pagination = mountWithOptions({ propsData });
    const bPagination = pagination.find(BPagination);

    expect(bPagination).not.toBeUndefined();
    expect(bPagination.vm.perPage).toBe(propsData.perPage);
    expect(bPagination.vm.totalRows).toBe(propsData.totalItems);
    expect(bPagination.vm.$attrs.limit).toBe(pagination.vm.paginationLimit);
  });

  it('should hide go to end buttons', () => {
    const pagination = mountWithOptions({
      propsData: {
        change,
        page: 1,
        perPage: 10,
        totalItems: 20,
      },
    });

    expect(pagination.vm.hideGotoEndButtons).toBe(true);
  });

  it('should show go to end buttons', () => {
    const pagination = mountWithOptions({
      propsData: {
        change,
        page: 1,
        perPage: 2,
        totalItems: 50,
      },
    });

    expect(pagination.vm.hideGotoEndButtons).toBe(false);
  });

  it('should change pagination limits on resize', () => {
    const pagination = mountWithOptions({ propsData });
    const mockResizeWidth = width => {
      window.innerWidth = width;
      const resizeEvent = document.createEvent('Event');
      resizeEvent.initEvent('resize', true, true);
      window.dispatchEvent(resizeEvent);
    };

    mockResizeWidth(breakpoints.sm);
    expect(pagination.vm.paginationLimit).toBe(1);

    mockResizeWidth(breakpoints.md);
    expect(pagination.vm.paginationLimit).toBe(3);

    mockResizeWidth(breakpoints.lg);
    expect(pagination.vm.paginationLimit).toBe(5);

    mockResizeWidth(breakpoints.xl);
    expect(pagination.vm.paginationLimit).toBe(11);
  });

  it('should not render when one page fits all items', () => {
    const pagination = mountWithOptions({
      propsData: {
        change,
        page: 1,
        perPage: 10,
        totalItems: 10,
      },
    });

    expect(pagination.html()).toBeUndefined();
  });

  it('should change currentPage when page prop changes', () => {
    const pagination = mountWithOptions({ propsData });
    pagination.setProps({ page: 10 });

    expect(pagination.vm.currentPage).toBe(10);
  });
});
