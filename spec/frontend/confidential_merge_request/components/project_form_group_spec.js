import { shallowMount, createLocalVue } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import ProjectFormGroup from '~/confidential_merge_request/components/project_form_group.vue';

const localVue = createLocalVue();
const mockData = [
  {
    id: 1,
    name_with_namespace: 'root / gitlab-foss',
    path_with_namespace: 'root/gitlab-foss',
    namespace: {
      full_path: 'root',
    },
  },
  {
    id: 2,
    name_with_namespace: 'test / gitlab-foss',
    path_with_namespace: 'test/gitlab-foss',
    namespace: {
      full_path: 'test',
    },
  },
];
let vm;
let mock;

function factory(projects = mockData) {
  mock = new MockAdapter(axios);
  mock.onGet(/api\/(.*)\/projects\/gitlab-org%2Fgitlab-foss\/forks/).reply(200, projects);

  vm = shallowMount(ProjectFormGroup, {
    localVue,
    propsData: {
      namespacePath: 'gitlab-org',
      projectPath: 'gitlab-org/gitlab-foss',
      newForkPath: 'https://test.com',
      helpPagePath: '/help',
    },
  });
}

describe('Confidential merge request project form group component', () => {
  afterEach(() => {
    mock.restore();
    vm.destroy();
  });

  it('renders fork dropdown', () => {
    factory();

    return localVue.nextTick(() => {
      expect(vm.element).toMatchSnapshot();
    });
  });

  it('sets selected project as first fork', () => {
    factory();

    return localVue.nextTick(() => {
      expect(vm.vm.selectedProject).toEqual({
        id: 1,
        name: 'root / gitlab-foss',
        pathWithNamespace: 'root/gitlab-foss',
        namespaceFullpath: 'root',
      });
    });
  });

  it('renders empty state when response is empty', () => {
    factory([]);

    return localVue.nextTick(() => {
      expect(vm.element).toMatchSnapshot();
    });
  });
});
