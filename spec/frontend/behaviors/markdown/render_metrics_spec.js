import Vue from 'vue';
import { TEST_HOST } from 'helpers/test_constants';
import renderMetrics from '~/behaviors/markdown/render_metrics';

const originalExtend = Vue.extend;

describe('Render metrics for Gitlab Flavoured Markdown', () => {
  const container = {
    Metrics() {},
  };

  let spyExtend;

  beforeEach(() => {
    Vue.extend = () => container.Metrics;
    spyExtend = jest.spyOn(Vue, 'extend');
  });

  afterEach(() => {
    Vue.extend = originalExtend;
  });

  it('does nothing when no elements are found', () => {
    renderMetrics([]);

    expect(spyExtend).not.toHaveBeenCalled();
  });

  it('renders a vue component when elements are found', () => {
    document.body.innerHTML = `<div class="element" data-dashboard-url="${TEST_HOST}"/>`;
    const element = document.querySelector('.element');

    renderMetrics([element]);

    expect(spyExtend).toHaveBeenCalled();
  });
});
