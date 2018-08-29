import { shallowMount } from '@vue/test-utils';
import GlPagination from '@gitlab-org/gitlab-ui/dist/base/pagination';
import PaginationLinks from '~/vue_shared/components/pagination_links.vue';
import { s__ } from '~/locale';

describe('Pagination links component', () => {
  const change = page => page;
  const pageInfo = {
    page: 3,
    perPage: 5,
    total: 30,
  };
  const translations = {
    firstText: s__('Pagination|« First'),
    prevText: s__('Pagination|Prev'),
    nextText: s__('Pagination|Next'),
    lastText: s__('Pagination|Last »'),
  };

  let paginationWrapper;
  let glPaginationWrapper;

  beforeEach(() => {
    paginationWrapper = shallowMount(PaginationLinks, {
      propsData: {
        change,
        pageInfo,
      },
    });
    glPaginationWrapper = paginationWrapper.find(GlPagination);
  });

  afterAll(() => {
    glPaginationWrapper.destroy();
    paginationWrapper.destroy();
  });

  it('should provide translated text to GitLab UI pagination', () => {
    Object.entries(translations).forEach(entry =>
      expect(glPaginationWrapper.vm.$attrs[entry[0]]).toBe(entry[1]),
    );
  });

  it('should pass change to GitLab UI pagination', () => {
    expect(glPaginationWrapper.vm.change).toBe(change);
  });

  it('should pass page from pageInfo to GitLab UI pagination', () => {
    expect(glPaginationWrapper.vm.page).toBe(pageInfo.page);
  });

  it('should pass per page from pageInfo to GitLab UI pagination', () => {
    expect(glPaginationWrapper.vm.perPage).toBe(pageInfo.perPage);
  });

  it('should pass total rows from pageInfo to GitLab UI pagination', () => {
    expect(glPaginationWrapper.vm.totalRows).toBe(pageInfo.total);
  });
});
