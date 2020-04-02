/**
 * @param {Array} queryResults - Array of Result objects
 * @param {Object} defaultConfig - Default chart config values (e.g. lineStyle, name)
 * @returns {Array} The formatted values
 */
// eslint-disable-next-line import/prefer-default-export
export const makeDataSeries = (queryResults, defaultConfig) =>
  queryResults
    .map(result => {
      // NaN values may disrupt avg., max. & min. calculations in the legend, filter them out
      const data = result.values.filter(([, value]) => !Number.isNaN(value));
      if (!data.length) {
        return null;
      }
      const series = { data };
      return {
        ...defaultConfig,
        ...series,
        name: getSeriesLabel(defaultConfig.name, result.metric),
      };
    })
    .filter(series => series !== null);

const getSeriesLabel = (queryLabel, metricAttributes) => {
  return (
    singleAttributeLabel(queryLabel, metricAttributes) ||
    templatedLabel(queryLabel, metricAttributes) ||
    multiMetricLabel(metricAttributes) ||
    `${queryLabel}`
  );
};

const singleAttributeLabel = (queryLabel, metricAttributes) => {
  if (!queryLabel) return;

  const relevantAttribute = queryLabel.toLowerCase().replace(' ', '_');
  const value = metricAttributes[relevantAttribute];

  if (!value) return;

  return `${queryLabel}: ${value}`;
};

const templatedLabel = (queryLabel, metricAttributes) => {
  if (!queryLabel) return;

  Object.keys(metricAttributes).forEach(templateVar => {
    const value = metricAttributes[templateVar];
    const regex = new RegExp(`{{\\s*${templateVar}\\s*}}`, 'g');

    queryLabel = queryLabel.replace(regex, value);
  });

  return queryLabel;
};

const multiMetricLabel = metricAttributes => {
  if (!Object.keys(metricAttributes).length) return;

  const attributePairs = [];

  Object.keys(metricAttributes).forEach(templateVar => {
    const value = metricAttributes[templateVar];

    attributePairs.push(`${templateVar}: ${value}`);
  });

  return attributePairs.join(', ');
};
