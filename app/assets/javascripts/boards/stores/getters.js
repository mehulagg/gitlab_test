import { inactiveId } from '../constants';

export default {
  getLabelToggleState: state => (state.isShowingLabels ? 'on' : 'off'),
  isSidebarOpen: state => state.activeId !== inactiveId,
};
