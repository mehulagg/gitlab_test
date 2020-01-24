import { mount } from '@vue/test-utils';
import DropdownValueComponent from '~/vue_shared/components/sidebar/labels_select/dropdown_value.vue';
import DropdownValueScopedLabel from '~/vue_shared/components/sidebar/labels_select/dropdown_value_scoped_label.vue';

import {
  mockConfig,
  mockLabels,
} from '../../../../../javascripts/vue_shared/components/sidebar/labels_select/mock_data';

const createComponent = (
  labels = mockLabels,
  labelFilterBasePath = mockConfig.labelFilterBasePath,
) =>
  mount(DropdownValueComponent, {
    propsData: {
      labels,
      labelFilterBasePath,
      enableScopedLabels: true,
    },
  });

describe('DropdownValueComponent', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent();
  });

  afterEach(() => {
    vm.destroy();
  });

  describe('computed', () => {
    describe('isEmpty', () => {
      it('returns true if `labels` prop is empty', () => {
        const vmEmptyLabels = createComponent([]);

        expect(vmEmptyLabels.classes()).not.toContain('has-labels');
        vmEmptyLabels.destroy();
      });

      it('returns false if `labels` prop is empty', () => {
        expect(vm.classes()).toContain('has-labels');
      });
    });
  });

  describe('methods', () => {
    describe('labelFilterUrl', () => {
      it('returns URL string starting with labelFilterBasePath and encoded label.title', () => {
        expect(vm.find(DropdownValueScopedLabel).props('labelFilterUrl')).toBe(
          '/gitlab-org/my-project/issues?label_name[]=Foo%3A%3ABar',
        );
      });
    });

    describe('showScopedLabels', () => {
      it('returns true if the label is scoped label', () => {
        expect(vm.findAll(DropdownValueScopedLabel).length).toEqual(1);
      });
    });
  });

  describe('template', () => {
    it('renders component container element with classes `hide-collapsed value issuable-show-labels`', () => {
      expect(vm.classes()).toContain('hide-collapsed', 'value', 'issuable-show-labels');
    });

    it('render slot content inside component when `labels` prop is empty', () => {
      const vmEmptyLabels = createComponent([]);

      expect(
        vmEmptyLabels
          .find('.text-secondary')
          .text()
          .trim(),
      ).toBe(mockConfig.emptyValueText);
      vmEmptyLabels.destroy();
    });

    it('renders label element with filter URL', () => {
      expect(vm.find('a').attributes('href')).toBe(
        '/gitlab-org/my-project/issues?label_name[]=Foo%20Label',
      );
    });

    it('renders label element', () => {
      const labelEl = vm.find('span.gl-label');

      expect(labelEl.exists()).toBe(true);
      expect(
        labelEl
          .find('.gl-label-text')
          .text()
          .trim(),
      ).toBe(mockLabels[0].title);
    });

    describe('label is of scoped-label type', () => {
      it('renders a gl-label-scoped span to incorporate 2 anchors', () => {
        expect(vm.find('span.gl-label.gl-label-scoped').exists()).toBe(true);
      });

      it('renders anchor tag containing question icon', () => {
        const anchor = vm.find('.gl-label-scoped a.gl-label-icon');

        expect(anchor.exists()).toBe(true);
        expect(anchor.find('svg.gl-icon.s12').exists()).toBe(true);
      });
    });
  });
});
