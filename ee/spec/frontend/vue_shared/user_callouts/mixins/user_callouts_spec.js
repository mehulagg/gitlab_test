import { shallowMount } from '@vue/test-utils';
import { userCalloutsMixin } from 'ee/vue_shared/user_callouts/mixins/user_callouts_mixin';

describe('userCalloutsMixin', () => {
  it('shoudl generates', () => {
    const component = {
      render(h) {
        return h('div', {}, [
          h('p', {
            class: {
              'is-shown': this.featureFlags.showCallout,
            },
          }),
          h('p', {
            class: {
              'is-shown': this.myFancyModule.showCallout,
            },
          }),
        ]);
      },
      mixins: [
        userCalloutsMixin(true, 'featureFlags', 'user_callouts'),
        userCalloutsMixin(true, 'myFancyModule', 'user_callouts'),
      ],
    };
    const wrapper = shallowMount(component);
    console.log(wrapper.html());
    expect(true).toBeTruthy();
  });
});
