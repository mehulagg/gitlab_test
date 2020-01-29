import { createLocalVue, mount, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import { GlButton, GlCard } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import EmbedGroup from '~/monitoring/components/embeds/embed_group.vue';
import MetricEmbed from '~/monitoring/components/embeds/metric_embed.vue';
import {
  dashboardEmbedProps,
  singleEmbedProps,
  initialEmbedGroupState,
  multipleEmbedProps,
} from './mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Embed Group', () => {
  let wrapper;
  let store;
  const metricsWithDataGetter = jest.fn();

  function mountComponent({ urls = [TEST_HOST], shallow = true, stubs } = {}) {
    const mountMethod = shallow ? shallowMount : mount;
    wrapper = mountMethod(EmbedGroup, {
      localVue,
      store,
      propsData: {
        urls,
      },
      stubs,
    });
  }

  beforeEach(() => {
    store = new Vuex.Store({
      modules: {
        embedGroup: {
          namespaced: true,
          actions: { addModule: jest.fn() },
          getters: { metricsWithData: metricsWithDataGetter },
          state: initialEmbedGroupState,
        },
      },
    });
    store.registerModule = jest.fn();
  });

  afterEach(() => {
    metricsWithDataGetter.mockReset();
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('interactivity', () => {
    it('hides the component when no chart data is loaded', () => {
      metricsWithDataGetter.mockReturnValue([]);
      mountComponent();

      expect(wrapper.find(GlCard).classes()).toContain('d-none');
    });

    it('shows the component when chart data is loaded', () => {
      metricsWithDataGetter.mockReturnValue([1]);
      mountComponent();

      expect(wrapper.find(GlCard).classes()).not.toContain('d-none');
    });

    it('is expanded by default', () => {
      metricsWithDataGetter.mockReturnValue([1]);
      mountComponent({ shallow: false, stubs: { MetricEmbed: '<div />' } });

      expect(wrapper.find('.card-body').classes()).not.toContain('d-none');
    });

    it('collapses when clicked', done => {
      metricsWithDataGetter.mockReturnValue([1]);
      mountComponent({ shallow: false, stubs: { MetricEmbed: '<div />' } });

      wrapper.find(GlButton).trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(wrapper.find('.card-body').classes()).toContain('d-none');
        done();
      });
    });
  });

  describe('single metrics', () => {
    beforeEach(() => {
      metricsWithDataGetter.mockReturnValue([1]);
      mountComponent();
    });

    it('renders an Embed component', () => {
      expect(wrapper.find(MetricEmbed).exists()).toBe(true);
    });

    it('passes the correct props to the Embed component', () => {
      expect(wrapper.find(MetricEmbed).props()).toEqual(singleEmbedProps());
    });
  });

  describe('dashboard metrics', () => {
    beforeEach(() => {
      metricsWithDataGetter.mockReturnValue([2]);
      mountComponent();
    });

    it('passes the correct props to the dashboard Embed component', () => {
      expect(wrapper.find(MetricEmbed).props()).toEqual(dashboardEmbedProps());
    });
  });

  describe('multiple metrics', () => {
    beforeEach(() => {
      metricsWithDataGetter.mockReturnValue([1, 1]);
      mountComponent({ urls: [TEST_HOST, TEST_HOST] });
    });

    it('creates Embed components', () => {
      expect(wrapper.findAll(MetricEmbed).length).toBe(2);
    });

    it('passes the correct props to the Embed components', () => {
      expect(wrapper.findAll(MetricEmbed).wrappers.map(item => item.props())).toEqual(
        multipleEmbedProps(),
      );
    });
  });
});
