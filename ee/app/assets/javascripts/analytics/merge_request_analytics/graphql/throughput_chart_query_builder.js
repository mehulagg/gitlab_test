import gql from 'graphql-tag';
import { computeMonthRangeData } from '../utils';

/**
 * A GraphQL query building function which accepts a
 * startDate and endDate, returning a parsed query string
 * which nests sub queries for each individual month.
 *
 * @param {Date} startDate the startDate for the data range
 * @param {Date} endDate the endDate for the data range
 *
 * @return {String} the parsed GraphQL query string
 */
export default (startDate = null, endDate = null) => {
  const monthData = computeMonthRangeData(startDate, endDate);

  if (!monthData.length) return '';

  const computedMonthData = monthData.map(value => {
    const { year, month, mergedAfter, mergedBefore } = value;

    // first: 0 is an optimization which makes sure we don't load merge request objects into memory (backend).
    // Currently when requesting counts we also load the first 100 records (preloader problem).
    return `${month}_${year}: mergeRequests(first: 0, mergedBefore: "${mergedBefore}", mergedAfter: "${mergedAfter}") { count }`;
  });

  return gql`
    query($fullPath: ID!) {
      throughputChartData: project(fullPath: $fullPath) {
        ${computedMonthData}
      }
    }
  `;
};
