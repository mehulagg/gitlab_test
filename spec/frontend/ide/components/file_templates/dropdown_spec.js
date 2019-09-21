import Vuex from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Dropdown from '~/ide/components/file_templates/dropdown.vue';

const mockJQueryOn = jest.fn();
const mockJQueryOff = jest.fn();
jest.mock('jquery', () =>
  jest.fn().mockImplementation(() => ({
    on: mockJQueryOn,
    off: mockJQueryOff,
  })),
);

const localVue = createLocalVue();
localVue.use(Vuex);

const findFirstOnCall = () => mockJQueryOn.mock.calls.find(([name]) => name === 'show.bs.dropdown');

describe('IDE file templates dropdown component', () => {
  let wrapper;

  const defaultProps = {
    label: 'label',
  };
  const fetchTemplateTypesMock = jest.fn();

  const findItemButtons = () => wrapper.findAll('button');
  const findSearch = () => wrapper.find('input[type="search"]');

  const createComponent = ({ props, state } = {}) => {
    const fakeStore = new Vuex.Store({
      modules: {
        fileTemplates: {
          namespaced: true,
          state: {
            templates: [],
            isLoading: false,
            ...state,
          },
          actions: {
            fetchTemplateTypes: fetchTemplateTypesMock,
          },
        },
      },
    });

    wrapper = shallowMount(Dropdown, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      store: fakeStore,
      localVue,
      sync: false,
    });
  };

  afterEach(() => {
    jest.clearAllMocks();
    wrapper.destroy();
    wrapper = null;
  });

  it('subscribes to `show.bs.dropdown` jquery event on mount', () => {
    createComponent();

    expect(mockJQueryOn).toHaveBeenCalledWith('show.bs.dropdown', expect.any(Function));
  });

  it('unsubscribes from `show.bs.dropdown` jquery event on unmount', () => {
    createComponent();
    const [, handlerFn] = findFirstOnCall();
    wrapper.destroy();

    expect(mockJQueryOff).toHaveBeenCalledWith('show.bs.dropdown', handlerFn);
  });

  it('calls clickItem on click', () => {
    const itemData = { name: 'test.yml ' };
    createComponent({ props: { data: [itemData] } });
    const item = findItemButtons().at(0);
    item.trigger('click');

    expect(wrapper.emitted().click[0][0]).toBe(itemData);
  });

  it('renders dropdown title', () => {
    const title = 'Test title';
    createComponent({ props: { title } });

    expect(wrapper.find('.dropdown-title').text()).toContain(title);
  });

  describe('in async mode', () => {
    const defaultAsyncProps = { ...defaultProps, isAsyncData: true };

    it('calls `fetchTemplateTypes` on `show.bs.dropdown` event', () => {
      createComponent({ props: defaultAsyncProps });
      const [, handlerFn] = findFirstOnCall();
      handlerFn();

      expect(fetchTemplateTypesMock).toHaveBeenCalled();
    });

    it('shows loader when isLoading is true', () => {
      createComponent({ props: defaultAsyncProps, state: { isLoading: true } });

      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });

    it('renders templates', () => {
      const templates = [{ name: 'file-1' }, { name: 'file-2' }];
      createComponent({
        props: { ...defaultAsyncProps, data: [{ name: 'should-never-appear ' }] },
        state: {
          templates,
        },
      });
      const items = findItemButtons();

      expect(
        templates.every(
          template => !items.filter(item => item.text().includes(template.name)).isEmpty(),
        ),
      ).toBe(true);
    });

    it('searches template data', () => {
      const templates = [{ name: 'match 1' }, { name: 'other' }, { name: 'match 2' }];
      const matches = ['match 1', 'match 2'];
      createComponent({
        props: { ...defaultAsyncProps, data: matches, searchable: true },
        state: { templates },
      });
      findSearch().setValue('match');
      return wrapper.vm.$nextTick().then(() => {
        const items = findItemButtons();

        expect(items.length).toBe(matches.length);
        expect(
          matches.every(entry => !items.filter(item => item.text().includes(entry)).isEmpty()),
        ).toBe(true);
      });
    });

    it('does not render input when `searchable` is true & `showLoading` is true', () => {
      createComponent({
        props: { ...defaultAsyncProps, searchable: true },
        state: { isLoading: true },
      });

      expect(findSearch().exists()).toBe(false);
    });
  });

  describe('in sync mode', () => {
    it('renders props data', () => {
      const data = [{ name: 'file-1' }, { name: 'file-2' }];
      createComponent({
        props: { data },
        state: {
          templates: [{ name: 'should-never-appear ' }],
        },
      });

      const items = findItemButtons();

      expect(items.length).toBe(data.length);
      expect(
        data.every(entry => !items.filter(item => item.text().includes(entry.name)).isEmpty()),
      ).toBe(true);
    });

    it('renders input when `searchable` is true', () => {
      createComponent({ props: { searchable: true } });

      expect(findSearch().exists()).toBe(true);
    });

    it('searches data', () => {
      const data = [{ name: 'match 1' }, { name: 'other' }, { name: 'match 2' }];
      const matches = ['match 1', 'match 2'];
      createComponent({ props: { searchable: true, data } });
      findSearch().setValue('match');
      return wrapper.vm.$nextTick().then(() => {
        const items = findItemButtons();

        expect(items.length).toBe(matches.length);
        expect(
          matches.every(entry => !items.filter(item => item.text().includes(entry)).isEmpty()),
        ).toBe(true);
      });
    });
  });
});
