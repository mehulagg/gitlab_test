import { useSmartResource, useFactoryArgs, unbox } from './resource';

describe('helpers/resources', () => {
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
