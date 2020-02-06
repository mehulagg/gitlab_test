import Vue from 'vue';

import milestoneItemComponent from 'ee/roadmap/components/milestone_item.vue';

import { getTimeframeForMonthsView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES } from 'ee/roadmap/constants';

import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { mockTimeframeInitialDate, mockMilestone2 } from '../mock_data';

const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);

const createComponent = ({
  presetType = PRESET_TYPES.MONTHS,
  milestone = mockMilestone2,
  timeframe = mockTimeframeMonths,
  timeframeItem = mockTimeframeMonths[0],
}) => {
  const Component = Vue.extend(milestoneItemComponent);

  return mountComponent(Component, {
    presetType,
    milestone,
    timeframe,
    timeframeItem,
  });
};

describe('MilestoneItemComponent', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent({});
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('computed', () => {
    describe('startDateValues', () => {
      it('returns object containing date parts from milestone.startDate', () => {
        expect(vm.startDateValues).toEqual(
          jasmine.objectContaining({
            day: mockMilestone2.startDate.getDay(),
            date: mockMilestone2.startDate.getDate(),
            month: mockMilestone2.startDate.getMonth(),
            year: mockMilestone2.startDate.getFullYear(),
            time: mockMilestone2.startDate.getTime(),
          }),
        );
      });
    });

    describe('endDateValues', () => {
      it('returns object containing date parts from milestone.endDate', () => {
        expect(vm.endDateValues).toEqual(
          jasmine.objectContaining({
            day: mockMilestone2.endDate.getDay(),
            date: mockMilestone2.endDate.getDate(),
            month: mockMilestone2.endDate.getMonth(),
            year: mockMilestone2.endDate.getFullYear(),
            time: mockMilestone2.endDate.getTime(),
          }),
        );
      });
    });

    it('returns Milestone.startDate when start date is within range', () => {
      vm = createComponent({ milestone: mockMilestone2 });

      expect(vm.startDate).toBe(mockMilestone2.startDate);
    });

    it('returns Milestone.originalStartDate when start date is out of range', () => {
      const mockStartDate = new Date(2018, 0, 1);
      const mockMilestoneItem = Object.assign({}, mockMilestone2, {
        startDateOutOfRange: true,
        originalStartDate: mockStartDate,
      });
      vm = createComponent({ milestone: mockMilestoneItem });

      expect(vm.startDate).toBe(mockStartDate);
    });
  });

  describe('endDate', () => {
    it('returns Milestone.endDate when end date is within range', () => {
      vm = createComponent({ milestone: mockMilestone2 });

      expect(vm.endDate).toBe(mockMilestone2.endDate);
    });

    it('returns Milestone.originalEndDate when end date is out of range', () => {
      const mockEndDate = new Date(2018, 0, 1);
      const mockMilestoneItem = Object.assign({}, mockMilestone2, {
        endDateOutOfRange: true,
        originalEndDate: mockEndDate,
      });
      vm = createComponent({ milestone: mockMilestoneItem });

      expect(vm.endDate).toBe(mockEndDate);
    });
  });

  describe('timeframeString', () => {
    it('returns timeframe string correctly when both start and end dates are defined', () => {
      vm = createComponent({ milestone: mockMilestone2 });

      expect(vm.timeframeString).toBe('Nov 10, 2017 - Jul 2, 2018');
    });

    it('returns timeframe string correctly when only start date is defined', () => {
      const mockMilestoneItem = Object.assign({}, mockMilestone2, {
        endDateUndefined: true,
      });
      vm = createComponent({ milestone: mockMilestoneItem });

      expect(vm.timeframeString).toBe('From Nov 10, 2017');
    });

    it('returns timeframe string correctly when only end date is defined', () => {
      const mockMilestoneItem = Object.assign({}, mockMilestone2, {
        startDateUndefined: true,
      });
      vm = createComponent({ milestone: mockMilestoneItem });

      expect(vm.timeframeString).toBe('Until Jul 2, 2018');
    });

    it('returns timeframe string with hidden year for start date when both start and end dates are from same year', () => {
      const mockMilestoneItem = Object.assign({}, mockMilestone2, {
        startDate: new Date(2018, 0, 1),
        endDate: new Date(2018, 3, 1),
      });
      vm = createComponent({ milestone: mockMilestoneItem });
      // Stub getHoverStyles to avoid error calling this.$root.$el.getBoundingClientRect()
      spyOn(vm, 'getHoverStyles').and.stub();

      expect(vm.timeframeString).toBe('Jan 1 - Apr 1, 2018');
    });
  });

  describe('template', () => {
    it('renders component container element class `milestone-item-details`', () => {
      expect(vm.$el.classList.contains('milestone-item-details')).toBeTruthy();
    });

    it('renders Milestone item link element with class `milestone-url`', () => {
      expect(vm.$el.querySelector('.milestone-url')).not.toBeNull();
    });

    it('renders Milestone timeline bar element with class `timeline-bar`', () => {
      expect(vm.$el.querySelector('.timeline-bar')).not.toBeNull();
    });

    it('renders Milestone title element with class `milestone-item-title`', () => {
      expect(vm.$el.querySelector('.milestone-item-title')).not.toBeNull();
    });
  });
});
