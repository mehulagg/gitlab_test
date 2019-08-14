import Vue from 'vue';
import FilterMixin from 'ee/analytics/cycle_analytics/mixins/filter_mixins';
import { shallowMount } from '@vue/test-utils';

describe('FilterMixin', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(
      Vue.extend({
        mixins: [FilterMixin],
        template: '<div></div>',
      }),
    );
  });

  describe('data', () => {
    describe('groupsQueryParams', () => {
      it('provides the groupsQueryParams object with the correct min_access_level', () => {
        expect(wrapper.vm.$data.groupsQueryParams.min_access_level).toBe(20);
      });
    });
  });
});
