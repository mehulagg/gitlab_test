import createStore from '../store';
import initialState from '../store/state';

const store = createStore();

const userCalloutsMixin = (showInitial, id, path) => {
  store.registerModule(id, {
    state: {
      ...initialState(),
      endpoint: path,
      showCallout: showInitial,
    },
  });
  const { dispatch, state } = store;
  return {
    computed: {
      [id]() {
        return { showCallout: state[id]?.showCallout };
      },
    },
    methods: {
      [`${id}dismiss`]() {
        dispatch('dismissCallout');
      },
    },
  };
};

export { userCalloutsMixin };
