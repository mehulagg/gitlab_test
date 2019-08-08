import Vue from 'vue';
import LinkedPipelinesColumn from 'ee/pipelines/components/graph/linked_pipelines_column.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import mockData from './linked_pipelines_mock_data';

describe('Linked Pipelines Column', () => {
  const Component = Vue.extend(LinkedPipelinesColumn);
  const props = {
    linkedPipelines: mockData.triggered,
    graphPosition: 'right',
  };
  let vm;

  beforeEach(() => {
    vm = mountComponent(Component, props);
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('renders the pipeline orientation', () => {
    expect(vm.$el.classList.contains('graph-position-right')).toBe(true);
  });

  it('has the correct number of linked pipeline child components', () => {
    expect(vm.$children.length).toBe(props.linkedPipelines.length);
  });

  it('renders the correct number of linked pipelines', () => {
    const linkedPipelineElements = vm.$el.querySelectorAll('.linked-pipeline');

    expect(linkedPipelineElements.length).toBe(props.linkedPipelines.length);
  });
});
