import { useSmartResource, useFactoryArgs, unbox } from './resource';

describe('helpers/resources', () => {
  describe('edge cases', () => {
    const teardown = jest.fn();

    describe('should not assert *directly* against the proxy', () => {
      const [subject] = useSmartResource(() => ({ id: 1 }), teardown);

      it('this passes for some reason', () => {
        expect(subject).toEqual({});
      });

      // eslint-disable-next-line jest/no-disabled-tests
      it.skip('this fails', () => {
        /**
         * expect(received).toStrictEqual(expected) // deep equality
         *
         * - Expected
         * + Received
         * - Object {}
         * + Object {
         * +   "_factory": undefined,
         * +   "_instance": undefined,
         * +   "_isCreated": undefined,
         * +   "_teardown": undefined,
         * + }
         */
        expect(subject).toStrictEqual({});
      });

      it('use unbox instead', () => {
        expect(unbox(subject)).toEqual({ id: 1 });
      });
    });

    describe('using multiple toFactoryArgs', () => {
      const [subject, createComponent] = useSmartResource((foo, bar = null) => ({ foo, bar }));

      describe('with args', () => {
        useFactoryArgs(subject, { c: 'c' });
        useFactoryArgs(subject, { d: 'd' });

        it('uses last factory args', () => {
          createComponent();

          expect(unbox(subject)).toEqual({
            foo: { d: 'd' },
            bar: null,
          });
        });
      });

      describe('with args again', () => {
        useFactoryArgs(subject, { x: 'x' });

        describe('even more args', () => {
          useFactoryArgs(subject, { y: 'y' });

          it('works when nested', () => {
            expect(unbox(subject)).toEqual({
              foo: { y: 'y' },
              bar: null,
            });
          });

          it('will not overwrite if used inside the it', () => {
            useFactoryArgs(subject, { m: 'm' });

            expect(unbox(subject)).toEqual({
              foo: { y: 'y' },
              bar: null,
            });
          });
        });

        it('will not accept anymore args', () => {
          createComponent({ z: 'z' }, 3);

          expect(unbox(subject)).toEqual({
            foo: { x: 'x' },
            bar: null,
          });
        });
      });

      it('reverts factory', () => {
        createComponent({ a: 'a', b: 'b' }, 1);

        expect(unbox(subject)).toEqual({
          foo: {
            a: 'a',
            b: 'b',
          },
          bar: 1,
        });
      });
    });

    describe('with referential loop', () => {
      let subjectB;

      const [subjectA] = useSmartResource(() => ({ b: unbox(subjectB), foo: 'lorem' }));
      [subjectB] = useSmartResource(() => ({ a: unbox(subjectA), foo: 'ipsum' }));

      it('blows up', () => {
        expect(() => unbox(subjectA)).toThrow(
          'Tried to create resource instance while it was already being created. Are we in a self referential loop?',
        );
      });
    });
  });

  describe('normal cases', () => {
    let id = 0;
    const instances = [];

    // Not using jest.fn() since it's automatically cleared after every test via
    // `clearMocks: true` in Jest's configuration.
    class MockResource {
      constructor(...args) {
        this.args = args;
        this.id = id;
        this.destroyed = false;
        instances.push(this);

        id += 1;
      }

      destroy() {
        this.destroyed = true;
      }

      static clearAll() {
        id = 0;
        while (instances.length > 0) {
          instances.pop();
        }
      }
    }

    describe('useSmartResource', () => {
      describe('lazy creation', () => {
        const [resource] = useSmartResource(() => new MockResource());

        beforeAll(MockResource.clearAll);

        it('does not create the resource if not accessed at all', () => {
          expect(instances).toEqual([]);
        });

        it('does not create the resource if no property is accessed', () => {
          // This assertion is intentionally weak to avoid implicit property
          // access, while still referencing the resource object.
          expect(resource).toBeTruthy();
          expect(instances).toEqual([]);
        });
      });

      describe('implicit creation', () => {
        const [resource] = useSmartResource(() => new MockResource());

        beforeAll(MockResource.clearAll);

        it('creates an instance when accessed', () => {
          expect(instances).toEqual([]);
          expect(resource.id).toBe(0);
          expect(instances).toMatchObject([{ id: 0 }]);
        });
      });

      describe('explicit creation', () => {
        const [resource, factory] = useSmartResource(() => new MockResource());

        beforeAll(MockResource.clearAll);

        it('can explicitly create a new instance via the provided factory', () => {
          factory();
          expect(instances).toMatchObject([{ id: 0 }]);

          // Accessing the resource now does _not_ recreate it within this test
          expect(resource.id).toBe(0);
          expect(instances).toMatchObject([{ id: 0 }]);
        });
      });

      describe('teardown', () => {
        const [resource] = useSmartResource(() => new MockResource(), res => res.destroy());

        beforeAll(MockResource.clearAll);

        it.each([0, 1, 2])('destroys each resource after each test', currentId => {
          expect(resource.id).toBe(currentId);
          expect(resource.destroyed).toBe(false);

          const previousInstances = instances.slice(0, -1);
          expect(previousInstances.every(instance => instance.destroyed)).toBe(true);
        });

        it('destroys all used resources', () => {
          // The resource is not referenced here to avoid implicit creation.
          expect(instances.every(instance => instance.destroyed)).toBe(true);
        });
      });
    });
  });
});
