export default {
  isActiveView: state => view => state.currentView === view,

  isAliveView: (state, getters) => view =>
    state.keepAliveViews[view] || (state.isOpen && getters.isActiveView(view)),
};
