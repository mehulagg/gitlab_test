import { inactiveId } from '~/boards/constants';

export default () => ({
  endpoints: {},
  boardType: null,
  disabled: false,
  showPromotion: false,
  isShowingLabels: true,
  activeId: inactiveId,
  sidebarType: '',
  boardLists: [],
  issuesByListId: {},
  issues: {},
  isLoadingIssues: false,
  filterParams: {},
  error: undefined,
  // TODO: remove after ce/ee split of board_content.vue
  isShowingEpicsSwimlanes: false,
});
