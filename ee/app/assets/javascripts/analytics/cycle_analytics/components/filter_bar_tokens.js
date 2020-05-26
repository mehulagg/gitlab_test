import { __ } from '~/locale';
import MilestoneToken from '../../shared/components/tokens/milestone_token.vue';
import LabelToken from '../../shared/components/tokens/label_token.vue';

export default [
  {
    icon: 'clock',
    title: __('Milestone'),
    type: 'milestone',
    token: MilestoneToken,
    milestones: this.milestones,
    unique: true,
    symbol: '%',
    isLoading: this.milestonesLoading,
  },
  {
    icon: 'labels',
    title: __('Label'),
    type: 'label',
    token: LabelToken,
    labels: this.labels,
    unique: false,
    symbol: '~',
    isLoading: this.labelsLoading,
  },
];
