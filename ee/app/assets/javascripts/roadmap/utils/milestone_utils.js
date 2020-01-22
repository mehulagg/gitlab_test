import { PRESET_TYPES } from '../constants';

/**
 * Returns array of milestones extracted from GraphQL response
 * discarding the `edges`->`node` nesting
 *
 * @param {Object} group
 */
export const extractGroupMilestones = edges =>
  edges.map(({ node, milestoneNode = node }) => ({
    ...milestoneNode,
  }));

/**
 * Returns date for timeframe
 * @param {Date, Object} timeframeItem
 * @param {String} presetType
 */
export const timeframeDate = (timeframeItem, presetType) => {
  if (presetType === PRESET_TYPES.QUARTERS) {
    return timeframeItem.range[0];
  }
  return timeframeItem;
};
