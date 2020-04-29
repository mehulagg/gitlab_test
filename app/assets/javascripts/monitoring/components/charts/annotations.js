import { graphTypes, symbolSizes } from '../../constants';

/**
 * Annotations and deployments are decoration layers on
 * top of the actual chart data. We use a scatter plot to
 * display this information. Each chart has its coordinate
 * system based on data and irrespective of the data, these
 * decorations have to be placed in specific locations.
 * For this reason, annotations have their own coordinate system,
 *
 * As of %12.9, only deployment icons, a type of annotations, need
 * to be displayed on the chart.
 *
 * Annotations and deployments co-exist in the same series as
 * they logically belong together. Annotations are passed as
 * markLines and markPoints while deployments are passed as
 * data points with custom icons.
 */

/**
 * Deployment icons, a type of annotation, are displayed
 * along the [min, max] range at height `pos`.
 */
const annotationsYAxisCoords = {
  min: 0,
  pos: 3, // 3% height of chart's grid
  max: 100,
};

/**
 * Annotation y axis min & max allows the deployment
 * icons to position correctly in the chart
 */
export const annotationsYAxis = {
  show: false,
  min: annotationsYAxisCoords.min,
  max: annotationsYAxisCoords.max,
  axisLabel: {
    // formatter fn required to trigger tooltip re-positioning
    formatter: () => {},
  },
};

/**
 * This method generates a decorative series that has
 * deployments as data points with custom icons and
 * annotations as markLines and markPoints
 *
 * @param {Array} deployments deployments data
 * @returns {Object} annotation series object
 */
export const generateAnnotationsSeries = ({ deployments = [] } = {}) => {
  // deployment data points
  const data = deployments.map(deployment => {
    return {
      name: 'deployments',
      value: [deployment.createdAt, annotationsYAxisCoords.pos],
      // style options
      symbol: deployment.icon,
      symbolSize: symbolSizes.default,
      itemStyle: {
        color: deployment.color,
      },
      // metadata that are accessible in `formatTooltipText` method
      tooltipData: {
        sha: deployment.sha.substring(0, 8),
        commitUrl: deployment.commitUrl,
      },
    };
  });

  return {
    name: 'annotations',
    type: graphTypes.annotationsData,
    yAxisIndex: 1, // annotationsYAxis index
    data,
  };
};
