/* eslint-disable import/prefer-default-export */

/**
 * This helper generates a component with only the slots you pass to it.
 * This is useful for writing tests to check your scoped slots are working without having to fully mount the component.
 * e.g.
 *
 * wrapper = shallowMount(MyComponent, {
 *   store,
 *   propsData: { … },
 *   stubs: {
 *     'my-component': createSlotStub('header-content', 'footer-content'),
 *   }
 * });
 *
 * @param {...string} slots Each argument is a slot you wish to generate
 * @returns {object} The shallow mounted, stubbed component
 */
export function createSlotStub(...slots) {
  const slotComponents = slots.map(slot =>
    slot ? `<slot name="${slot}"></slot>` : `<slot></slot>`,
  );

  return {
    template: `<div>${slotComponents}</div>`,
  };
}
