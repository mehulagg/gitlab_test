import AreaBasicExample from './area.basic.example.vue';
import AreaUpperThresholdExample from './area.upper_threshold.example.vue';
import AreaLowerThresholdExample from './area.lower_threshold.example.vue';

export default [
  {
    name: 'Basic',
    items: [
      {
        id: 'area-basic',
        name: 'Basic',
        description: 'Basic Area Chart',
        component: AreaBasicExample,
      },
    ],
  },
  {
    name: 'Thresholds',
    items: [
      {
        id: 'area-upper-threshold',
        name: 'Upper Threshold',
        description: 'Area chart with upper numeric threshold',
        component: AreaUpperThresholdExample,
      },
      {
        id: 'area-lower-threshold',
        name: 'Lower Threshold',
        description: 'Area chart with lower numeric threshold',
        component: AreaLowerThresholdExample,
      },
    ],
  },
];
