import { shallowMount } from '@vue/test-utils';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import ConfidentialFilter from '~/search/confidential_filter/components/confidential_filter.vue';
import { FILTER_STATES } from '~/search/confidential_filter/constants';
import * as urlUtils from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn(),
  setUrlParams: jest.fn(),
}));

function createComponent(props = { scope: 'issues' }) {
  return shallowMount(ConfidentialFilter, {
    propsData: {
      ...props,
    },
  });
}

describe('ConfidentialFilter', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGlDropdown = () => wrapper.find(GlDropdown);
  const findGlDropdownItems = () => findGlDropdown().findAll(GlDropdownItem);
  const findDropdownItemsText = () => findGlDropdownItems().wrappers.map(w => w.text());
  const firstDropDownItem = () => findGlDropdownItems().at(0);

  describe('template', () => {
    describe.each`
      scope               | showConfidentialDropdown
      ${'issues'}         | ${true}
      ${'projects'}       | ${false}
      ${'milestones'}     | ${false}
      ${'users'}          | ${false}
      ${'merge_requests'} | ${false}
      ${'notes'}          | ${false}
      ${'wiki_blobs'}     | ${false}
      ${'blobs'}          | ${false}
    `(`confidential dropdown`, ({ scope, showConfidentialDropdown }) => {
      beforeEach(() => {
        wrapper = createComponent({ scope });
      });

      it(`does${showConfidentialDropdown ? '' : ' not'} render when scope is ${scope}`, () => {
        expect(findGlDropdown().exists()).toBe(showConfidentialDropdown);
      });
    });

    describe('Filter options', () => {
      it('renders a dropdown item for each filterOption', () => {
        expect(findDropdownItemsText()).toStrictEqual(
          Object.keys(FILTER_STATES).map(key => {
            return FILTER_STATES[key].label;
          }),
        );
      });

      it('clicking a dropdown item calls setUrlParams', () => {
        const confidential = FILTER_STATES[Object.keys(FILTER_STATES)[0]].value;
        firstDropDownItem().vm.$emit('click');

        expect(urlUtils.setUrlParams).toHaveBeenCalledWith({ confidential });
      });

      it('clicking a dropdown item calls visitUrl', () => {
        firstDropDownItem().vm.$emit('click');

        expect(urlUtils.visitUrl).toHaveBeenCalled();
      });
    });
  });
});
