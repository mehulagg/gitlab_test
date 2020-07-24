/* eslint-disable no-underscore-dangle */
import { noop, identity } from 'lodash';

const INTERNAL_RESOURCE = '$_resource';

/**
 * This proxy handler is used to wrap a Resource and delegates all props to the Resource.instance
 * unless the prop is the special INTERNAL_RESOURCE used by internal methods.
 */
const PROXY_HANDLER = {
  /**
   * Delegate all props to the instance, unless we're referencing our special lifecycle functions
   */
  get(resource, prop) {
    if (prop === INTERNAL_RESOURCE) {
      return resource;
    }

    return resource.instance[prop];
  },
  /**
   * Delegate all props to the instance
   */
  set(resource, prop, value) {
    if (prop === INTERNAL_RESOURCE) {
      throw new Error('Cannot set internal resource');
    }

    const { instance } = resource;

    instance[prop] = value;

    return true;
  },
};

/**
 * A SmartResource contains some lifecycle methods (e.g., factory) and keeps track if it's been created or not.
 *
 * By client's outside this module, the SmartResource should not be handled directly. Instead, all props are
 * delegated to the SmartResource's instance.
 *
 * - Access to the instance when not created yet, runs the factory.
 * - The creation of the instance is deferred.
 */
class SmartResource {
  constructor(factory = noop, teardown = noop) {
    this._factory = factory;
    this._teardown = teardown;
    this._isCreated = false;
    this._instance = null;
  }

  get instance() {
    if (this._isCreated) {
      return this._instance;
    }

    return this.create();
  }

  create(...args) {
    if (this._isCreated) {
      throw new Error('Cannot create resource twice');
    }

    this._instance = this._factory(...args);
    this._isCreated = true;
    return this._instance;
  }

  teardown() {
    if (!this._isCreated) {
      return;
    }

    this._isCreated = false;
    this._teardown(this._instance);
    this._instance = null;
  }
}

/**
 * Given a proxy wrapping a resource, this method unboxes the proxy to return the actual resource object.
 *
 * This is helpful for internal methods that need to access the resource's state like lifecycle methods.
 *
 * @param {Proxy} proxy
 */
const unboxResourceProxy = proxy => {
  return proxy[INTERNAL_RESOURCE];
};

const createResourceInstance = (resourceProxy, ...args) => {
  const resource = unboxResourceProxy(resourceProxy);

  resource.create(...args);
};

/**
 *
 * @param { Proxy } resourceProxy The proxy wrapping an underlying SmartResource
 * @param { (origFactory:Function) => Function } factory A function that returns a new factory function based on the old one.
 * @param { Function } teardown (optional) The new teardown to use in this context
 */
const useFactory = (resourceProxy, factory = identity, teardown = null) => {
  const resource = unboxResourceProxy(resourceProxy);

  let origFactory;

  // beforeAll will always run before any beforeEach, so we're able to overwrite our factory method!
  beforeAll(() => {
    origFactory = resource._factory;
    resource._factory = factory(origFactory);
  });

  // after we exit our context (i.e. inner describe), let's go back to the previous factory/teardown.
  afterAll(() => {
    resource._factory = origFactory;
  });

  // optionally overwrite teardown if argument is given
  if (teardown) {
    let origTeardown;

    beforeAll(() => {
      origTeardown = resource._teardown;
      resource._teardown = teardown;
    });

    afterAll(() => {
      resource._teardown = origTeardown;
    });
  }
};

export const useFactoryArgs = (resourceProxy, ...factoryArgs) => {
  useFactory(resourceProxy, factory => () => factory(...factoryArgs));
};

/**
 * This function uses the given factory and teardown to create a smart resource that whose
 * lifecycle is automatically handled.
 *
 * It returns a [resource, resourceFactory] where
 *
 * - `resource` is a proxy that wraps a deferred instance of whatever is created by `factory`.
 * - `resourceFactory` is a method which can be used to trigger the immediate creation of the underlying resource instance.
 *
 * Some notes!
 *
 * - factory() is **not** called right away.
 *   - It is called whenever the first time the resource is referenced (similar to `let()` in RSpec)
 *   - Or it is called whenever the resourceFactory is triggered
 * - teardown() is called in after each
 *
 * Examples:
 *
 * ```javascript
 * import { useSmartResource, useFactoryArgs } from 'helpers/resources';
 *
 * describe('silly spec', () => {
 *   const [store] = useSmartResource(createStore);
 *   const [wrapper] = useSmartResource((props = {}) => shallowMount(MyComponent, { propsData: props, store }), x => x.destroy());
 *
 *   describe('with flag 2', () => {
 *     useFactoryArgs(wrapper, { flag: 2 });
 *
 *     // Now, whenever wrapper is created it will pass these arguments to the original factory
 *     // but only in this describe context
 *
 *     it('does things', () => {
 *       // Note that we don't need to explicitly createWrapper!
 *       expect(wrapper.text()).toContain('I have 2 flags');
 *     });
 *   });
 *
 *   it('works', () => {
 *     expect(wrapper.text()).toBe('');
 *   });
 * });
 * ```
 *
 * @template T
 * @returns { [T, (...args) => void] }
 * @param { (...args) => T } factory
 * @param { (T) => void } teardown
 */
export const useSmartResource = (factory = noop, teardown = noop) => {
  const resource = new SmartResource(factory, teardown);

  afterEach(() => resource.teardown());

  const proxy = new Proxy(resource, PROXY_HANDLER);

  return [proxy, (...args) => createResourceInstance(proxy, ...args)];
};
