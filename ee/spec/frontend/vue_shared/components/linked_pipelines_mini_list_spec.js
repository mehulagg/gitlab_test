import { shallowMount } from '@vue/test-utils';
import Icon from '~/vue_shared/components/icon.vue';
import LinkedPipelinesMiniList from 'ee/vue_shared/components/linked_pipelines_mini_list.vue';
import mockData from './linked_pipelines_mock_data';

describe('Linked pipeline mini list', () => {
  let wrapper;

  const factory = (propsData = {}) => {
    wrapper = shallowMount(LinkedPipelinesMiniList, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when passed an upstream pipeline as prop', () => {
    beforeEach(() => {
      factory({
        triggeredBy: [mockData.triggered_by],
      });
    });

    it('should render one linked pipeline item', () => {
      expect(wrapper.findAll('.linked-pipeline-mini-item').length).toBe(1);
    });

    it('should render a linked pipeline with the correct href', () => {
      const linkElement = wrapper.find('.linked-pipeline-mini-item');

      expect(linkElement.attributes('href')).toBe('/gitlab-org/gitlab-foss/pipelines/129');
    });

    it('should render one ci status icon', () => {
      expect(wrapper.findAll('.linked-pipeline-mini-item').length).toBe(1);
    });

    it('should render the correct ci status icon', () => {
      const iconElement = wrapper.find('.linked-pipeline-mini-item');

      expect(iconElement.classes('ci-status-icon-running')).toBe(true);
    });

    it('should render an arrow icon', () => {
      const iconElement = wrapper.find('.arrow-icon');

      expect(iconElement).not.toBeNull();
      expect(iconElement.html()).toContain('long-arrow');
    });

    it('should have an activated tooltip', () => {
      const itemElement = wrapper.find('.linked-pipeline-mini-item');

      expect(itemElement.attributes('data-original-title')).toBe('GitLabCE - running');
    });

    it('should correctly set is-upstream', () => {
      expect(wrapper.classes('is-upstream')).toBe(true);
    });

    it('should correctly compute shouldRenderCounter', () => {
      expect(wrapper.vm.shouldRenderCounter).toBe(false);
    });

    it('should not render the pipeline counter', () => {
      expect(wrapper.find('.linked-pipelines-counter').exists()).toBeFalsy();
    });
  });

  describe('when passed downstream pipelines as props', () => {
    beforeEach(() => {
      factory({
        triggered: mockData.triggered,
        pipelinePath: 'my/pipeline/path',
      });
    });

    it('should render three linked pipeline item', () => {
      expect(
        wrapper.findAll('.linked-pipeline-mini-item:not(.linked-pipelines-counter)').length,
      ).toBe(3);
    });

    it('should render three ci status icons', () => {
      expect(wrapper.findAll(Icon).wrappers.filter(w => !w.classes('arrow-icon')).length).toBe(3);
    });

    it('should render the correct ci status icon', () => {
      const iconElement = wrapper.find('.linked-pipeline-mini-item');

      expect(iconElement.exists()).toBe(true);
      expect(iconElement.classes('ci-status-icon-running')).toBe(true);
    });

    it('should render an arrow icon', () => {
      const iconElement = wrapper.find('.arrow-icon');

      expect(iconElement).not.toBeNull();
      expect(iconElement.html()).toContain('long-arrow');
    });

    it('should have prepped tooltips', () => {
      const itemElement = wrapper.findAll('.linked-pipeline-mini-item').at(2);

      expect(itemElement.attributes('data-original-title')).toBe('GitLabCE - running');
    });

    it('should correctly set is-downstream', () => {
      expect(wrapper.classes('is-downstream')).toBe(true);
    });

    it('should correctly compute shouldRenderCounter', () => {
      expect(wrapper.vm.shouldRenderCounter).toBe(true);
    });

    it('should correctly trim linkedPipelines', () => {
      expect(wrapper.vm.triggered.length).toBe(6);
      expect(wrapper.vm.linkedPipelinesTrimmed.length).toBe(3);
    });

    it('should render the pipeline counter', () => {
      expect(wrapper.find('.linked-pipelines-counter').exists()).toBeTruthy();
    });

    it('should set the correct pipeline path', () => {
      expect(wrapper.find('.linked-pipelines-counter').attributes('href')).toBe('my/pipeline/path');
    });

    it('should render the correct counterTooltipText', () => {
      expect(wrapper.find('.linked-pipelines-counter').attributes('data-original-title')).toBe(
        wrapper.vm.counterTooltipText,
      );
    });
  });
});
