/* eslint-disable import/prefer-default-export */

/**
 * @param {Array} queryResults - Array of Result objects
 * @param {Object} defaultConfig - Default chart config values (e.g. lineStyle, name)
 * @returns {Array} The formatted values
 */
export const makeDataSeries = (queryResults, defaultConfig) =>
  queryResults
    .map(result => {
      const data = result.values.filter(([, value]) => !Number.isNaN(value));
      if (!data.length) {
        return null;
      }
      const relevantMetric = defaultConfig.name.toLowerCase().replace(' ', '_');
      const name = result.metric[relevantMetric];
      const series = { data };
      if (name) {
        series.name = `${defaultConfig.name}: ${name}`;
      } else {
        series.name = defaultConfig.name;
        Object.keys(result.metric).forEach(variable => {
          const value = result.metric[variable];
          const regex = new RegExp(`{{\\s*${variable}\\s*}}`, 'g');

          series.name = series.name.replace(regex, value);
        });
      }

      return { ...defaultConfig, ...series };
    })
    .filter(series => series !== null);
