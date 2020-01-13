import * as milestoneUtils from 'ee/roadmap/utils/milestone_utils';

import { mockGroupMilestonesQueryResponse } from '../mock_data';

describe('extractGroupMilestones', () => {
  it('returns array of epics with `edges->nodes` nesting removed', () => {
    const { edges } = mockGroupMilestonesQueryResponse.data.group.milestones;
    const extractedMilestones = milestoneUtils.extractGroupMilestones(edges);

    expect(extractedMilestones.length).toBe(edges.length);
    expect(extractedMilestones[0]).toEqual(
      jasmine.objectContaining({
        ...edges[0].node,
        groupName: edges[0].node.group.name,
        groupFullName: edges[0].node.group.fullName,
      }),
    );
  });
});
