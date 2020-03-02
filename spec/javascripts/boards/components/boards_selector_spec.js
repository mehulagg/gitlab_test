import Vue from 'vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { TEST_HOST } from 'spec/test_constants';
import BoardsSelector from '~/boards/components/boards_selector.vue';
import boardsStore from '~/boards/stores/boards_store';

const throttleDuration = 1;

function boardGenerator(n) {
  return new Array(n).fill().map((board, index) => {
    const id = `${index}`;
    const name = `board${id}`;

    return {
      id,
      name,
    };
  });
}

describe('BoardsSelector', () => {
  let vm;
  let $apollo;
  let allBoardsResponse;
  let recentBoardsResponse;
  const boards = boardGenerator(20);
  const recentBoards = boardGenerator(5);

  const fillSearchBox = filterTerm => {
    const { searchBox } = vm.$refs;
    const searchBoxInput = searchBox.$el.querySelector('input');
    searchBoxInput.value = filterTerm;
    searchBoxInput.dispatchEvent(new Event('input'));
  };

  const createComponent = () => {
    const Component = Vue.extend(BoardsSelector);
    vm = new Component({
      mocks: { $apollo },
      propsData: {
        throttleDuration,
        currentBoard: {
          id: 1,
          name: 'Development',
          milestone_id: null,
          weight: null,
          assignee_id: null,
          labels: [],
        },
        milestonePath: `${TEST_HOST}/milestone/path`,
        boardBaseUrl: `${TEST_HOST}/board/base/url`,
        hasMissingBoards: false,
        canAdminBoard: true,
        multipleIssueBoardsAvailable: true,
        labelsPath: `${TEST_HOST}/labels/path`,
        projectId: 42,
        groupId: 19,
        scopedIssueBoardFeatureEnabled: true,
        weights: [],
      },
    }).$mount('.js-boards-selector');

    // spyOn(vm.$apollo, 'addSmartQuery').and.stub();

    // Emits gl-dropdown show event to simulate the dropdown is opened at initialization time
    vm.$children[0].$emit('show');
  };

  beforeEach(() => {
    setFixtures('<div class="js-boards-selector"></div>');
    window.gl = window.gl || {};

    boardsStore.setEndpoints({
      boardsEndpoint: '',
      recentBoardsEndpoint: '',
      listsEndpoint: '',
      bulkUpdatePath: '',
      boardId: '',
    });

    $apollo = {
      queries: {
        boards: {
          loading: false,
        },
      },
    };
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('with data', () => {
    beforeEach(done => {
      allBoardsResponse = Promise.resolve({
        data: {
          group: {
            boards: {
              edges: boards.map(board => ({ node: board })),
            },
          },
        },
      });
      recentBoardsResponse = Promise.resolve({
        data: recentBoards,
      });

      spyOn(boardsStore, 'recentBoards').and.returnValue(recentBoardsResponse);

      createComponent();

      Promise.all([allBoardsResponse, recentBoardsResponse])
        .then(() => vm.$nextTick())
        .then(done)
        .catch(done.fail);
    });

    describe('filtering', () => {
      const numberOfDropdownItems = () => vm.$el.querySelectorAll('.js-dropdown-item').length;

      it('shows all boards without filtering', done => {
        vm.$nextTick()
          .then(() => {
            expect(numberOfDropdownItems()).toBe(boards.length + recentBoards.length);
          })
          .then(done)
          .catch(done.fail);
      });

      it('shows only matching boards when filtering', done => {
        const filterTerm = 'board1';
        const expectedCount = boards.filter(board => board.name.includes(filterTerm)).length;

        fillSearchBox(filterTerm);

        vm.$nextTick()
          .then(() => {
            expect(numberOfDropdownItems()).toBe(expectedCount);
          })
          .then(done)
          .catch(done.fail);
      });

      it('shows message if there are no matching boards', done => {
        fillSearchBox('does not exist');

        vm.$nextTick()
          .then(() => {
            expect(numberOfDropdownItems()).toBe(0);
            expect(vm.$el).toContainText('No matching boards found');
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('recent boards section', () => {
      it('shows only when boards are greater than 10', done => {
        vm.$nextTick()
          .then(() => {
            const headerEls = vm.$el.querySelectorAll('.dropdown-bold-header');

            const expectedCount = 2; // Recent + All

            expect(expectedCount).toBe(headerEls.length);
          })
          .then(done)
          .catch(done.fail);
      });

      it('does not show when boards are less than 10', done => {
        spyOn(vm, 'initScrollFade');
        spyOn(vm, 'setScrollFade');

        vm.$nextTick()
          .then(() => {
            vm.boards = vm.boards.slice(0, 5);
          })
          .then(vm.$nextTick)
          .then(() => {
            const headerEls = vm.$el.querySelectorAll('.dropdown-bold-header');
            const expectedCount = 0;

            expect(expectedCount).toBe(headerEls.length);
          })
          .then(done)
          .catch(done.fail);
      });

      it('does not show when recentBoards api returns empty array', done => {
        vm.$nextTick()
          .then(() => {
            vm.recentBoards = [];
          })
          .then(vm.$nextTick)
          .then(() => {
            const headerEls = vm.$el.querySelectorAll('.dropdown-bold-header');
            const expectedCount = 0;

            expect(expectedCount).toBe(headerEls.length);
          })
          .then(done)
          .catch(done.fail);
      });

      it('does not show when search is active', done => {
        fillSearchBox('Random string');

        vm.$nextTick()
          .then(() => {
            const headerEls = vm.$el.querySelectorAll('.dropdown-bold-header');
            const expectedCount = 0;

            expect(expectedCount).toBe(headerEls.length);
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });

  describe('with errors', () => {
    beforeEach(done => {
      recentBoardsResponse = Promise.resolve({
        data: recentBoards,
      });

      spyOn(boardsStore, 'recentBoards').and.returnValue(recentBoardsResponse);
      // spyOn(gqlClient, 'query').and.returnValue(Promise.reject());

      createComponent();

      Promise.all([allBoardsResponse, recentBoardsResponse])
        .then(() => vm.$nextTick())
        .then(done)
        .catch(done.fail);
    });

    it('renders empty list', () => {
      expect(vm.$el).toContainText('No matching boards found');
    });
  });
});
