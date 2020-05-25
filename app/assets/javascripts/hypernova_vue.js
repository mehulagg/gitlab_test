import Vue from 'vue';
import Vuex from 'vuex';
import hypernova, { serialize, load } from 'hypernova';
import Translate from './vue_shared/translate';

Vue.use(Vuex);
Vue.use(Translate);

export const mountComponent = (Component, node, data) => {
  const vm = new Component({
    propsData: data,
  });

  vm.$mount(node.children[0]);

  return vm;
};

export default (name, ComponentDefinition, createStore) =>
  hypernova({
    client() {
      if (IS_SERVER) {
        const { createRenderer } = require('vue-server-renderer');
        return propsData => {
          const store = createStore();

          window.gon = propsData.gon;
          delete propsData.gon;

          const Component = Vue.extend({
            ...ComponentDefinition,
            store,
          });

          const vm = new Component({
            propsData,
          });

          const renderer = createRenderer();
          console.log(`Request for: ${name}`, propsData);

          return renderer
            .renderToString(vm)
            .then(contents => serialize(name, contents, { propsData, state: vm.$store.state }));
        };
      }

      const payloads = load(name);
      if (payloads) {
        payloads.forEach(payload => {
          const { node, data } = payload;
          const { propsData, state } = data;

          const store = createStore();
          store.replaceState(state);

          const Component = Vue.extend({
            ...ComponentDefinition,
            store,
          });

          mountComponent(Component, node, propsData);
        });
      }

      return ComponentDefinition;
    },
  });
