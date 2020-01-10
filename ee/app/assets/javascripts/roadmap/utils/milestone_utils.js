/**
 * Returns array of epics extracted from GraphQL response
 * discarding the `edges`->`node` nesting
 *
 * @param {Object} group
 */
export const extractGroupMilestones = edges =>
  edges.map(({ node, milestoneNode = node }) => ({
    ...milestoneNode,
  }));