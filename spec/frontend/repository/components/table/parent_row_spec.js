import { shallowMount, RouterLinkStub } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import ParentRow from '~/repository/components/table/parent_row.vue';

let vm;
let $router;

function factory(path, loadingPath) {
  $router = {
    push: jest.fn(),
  };

  vm = shallowMount(ParentRow, {
    propsData: {
      commitRef: 'master',
      path,
      loadingPath,
    },
    stubs: {
      RouterLink: RouterLinkStub,
    },
    mocks: {
      $router,
    },
  });
}

describe('Repository parent row component', () => {
  afterEach(() => {
    vm.destroy();
  });

  it.each`
    path                  | to
    ${'app'}              | ${'/-/tree/master/'}
    ${'app/assets'}       | ${'/-/tree/master/app'}
    ${'app/assets#/test'} | ${'/-/tree/master/app/assets%23'}
  `('renders link in $path to $to', ({ path, to }) => {
    factory(path);

    expect(vm.find(RouterLinkStub).props('to')).toEqual({
      path: to,
    });
  });

  it('renders loading icon when loading parent', () => {
    factory('app/assets', 'app');

    expect(vm.find(GlLoadingIcon).exists()).toBe(true);
  });
});
