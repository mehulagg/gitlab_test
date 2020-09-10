import VueApollo from 'vue-apollo';
import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import TodoButton from '~/vue_shared/components/todo_button.vue';
import DesignTodoButton from '~/design_management/components/design_todo_button.vue';
import createDesignTodoMutation from '~/design_management/graphql/mutations/create_design_todo.mutation.graphql';
import getDesignListQuery from '~/design_management/graphql/queries/get_design_list.query.graphql';
import permissionsQuery from '~/design_management/graphql/queries/design_permissions.query.graphql';
import todoMarkDoneMutation from '~/graphql_shared/mutations/todo_mark_done.mutation.graphql';
import mockDesign from '../mock_data/design';
import { designListQueryResponse, permissionsQueryResponse } from '../mock_data/apollo_mock';

const mockDesignWithPendingTodos = {
  ...mockDesign,
  currentUserTodos: {
    nodes: [
      {
        id: 'todo-id',
      },
    ],
  },
};

const mutate = jest.fn().mockResolvedValue();
const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Design management design todo button', () => {
  let wrapper;
  let fakeApollo;

  function createComponent(props = {}, { mountFn = shallowMount } = {}) {
    wrapper = mountFn(DesignTodoButton, {
      propsData: {
        design: mockDesign,
        ...props,
      },
      provide: {
        projectPath: 'project-path',
        issueIid: '10',
      },
      mocks: {
        $route: {
          params: {
            id: 'my-design.jpg',
          },
          query: {},
        },
        $apollo: {
          mutate,
        },
      },
    });
  }

  function createComponentWithApollo(props = {}) {
    localVue.use(VueApollo);

    const requestHandlers = [
      [getDesignListQuery, jest.fn().mockResolvedValue(designListQueryResponse)],
      [permissionsQuery, jest.fn().mockResolvedValue(permissionsQueryResponse)],
      [
        createDesignTodoMutation,
        jest.fn().mockResolvedValue({
          createDesignTodo: {
            id: 'git://gitlab/Todo/123',
          },
        }),
      ],
    ];

    fakeApollo = createMockApollo(requestHandlers);
    wrapper = mount(DesignTodoButton, {
      localVue,
      apolloProvider: fakeApollo,
      provide: {
        projectPath: 'project-path',
        issueIid: '10',
      },
      mocks: {
        $route: {
          params: {
            id: 'my-design.jpg',
          },
          query: {},
        },
      },
      propsData: {
        design: mockDesign,
        ...props,
      },
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders TodoButton component', () => {
    expect(wrapper.find(TodoButton).exists()).toBe(true);
  });

  describe('when design has a pending todo', () => {
    beforeEach(() => {
      createComponent({ design: mockDesignWithPendingTodos }, { mountFn: mount });
    });

    it('renders correct button text', () => {
      expect(wrapper.text()).toBe('Mark as done');
    });

    describe('when clicked', () => {
      beforeEach(() => {
        createComponent({ design: mockDesignWithPendingTodos }, { mountFn: mount });
        wrapper.trigger('click');
        return wrapper.vm.$nextTick();
      });

      it('calls `$apollo.mutate` with the `todoMarkDone` mutation and variables containing `id`', async () => {
        const todoMarkDoneMutationVariables = {
          mutation: todoMarkDoneMutation,
          update: expect.anything(),
          variables: {
            id: 'todo-id',
          },
        };

        expect(mutate).toHaveBeenCalledTimes(1);
        expect(mutate).toHaveBeenCalledWith(todoMarkDoneMutationVariables);
      });
    });
  });

  describe('when design has no pending todos', () => {
    beforeEach(() => {
      createComponent({}, { mountFn: mount });
    });

    it('renders correct button text', () => {
      expect(wrapper.text()).toBe('Add a To-Do');
    });

    describe('when clicked', () => {
      beforeEach(() => {
        createComponent({}, { mountFn: mount });
        wrapper.trigger('click');
        return wrapper.vm.$nextTick();
      });

      it('calls `$apollo.mutate` with the `createDesignTodoMutation` mutation and variables containing `issuable_id`, `issue_id`, & `projectPath`', async () => {
        const createDesignTodoMutationVariables = {
          mutation: createDesignTodoMutation,
          update: expect.anything(),
          variables: {
            atVersion: null,
            filenames: ['my-design.jpg'],
            issueId: '1',
            issueIid: '10',
            projectPath: 'project-path',
          },
        };

        expect(mutate).toHaveBeenCalledTimes(1);
        expect(mutate).toHaveBeenCalledWith(createDesignTodoMutationVariables);
      });
    });
  });

  describe('with mocked Apollo client', () => {
    describe('when design has no pending todos', () => {
      it('renders `Add a To-Do` text in button', async () => {
        createComponentWithApollo();

        await jest.runOnlyPendingTimers();
        await wrapper.vm.$nextTick();

        expect(wrapper.text()).toBe('Add a To-Do');
      });

      describe('when clicked', () => {
        it('button text becomes `Mark as resolved`', async () => {
          createComponentWithApollo();
          await jest.runOnlyPendingTimers();

          wrapper.trigger('click');
          await wrapper.vm.$nextTick();

          expect(wrapper.text()).toBe('Mark as resolved');
        });
      });
    });
  });
});
