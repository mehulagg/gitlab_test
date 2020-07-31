import { inactiveId } from '~/boards/constants';

export default () => ({
  endpoints: {},
  isShowingLabels: true,
  activeId: inactiveId,
  issuesByListId: [],
  sidebarType: 'Issuable', // todo: needs to be dynamic and an enum
});
