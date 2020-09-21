import { shallowMount } from '@vue/test-utils';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import PackagePath from '~/packages/shared/components/package_path.vue';

describe('PackagePath', () => {
  let wrapper;

  const mountComponent = (propsData = { path: 'foo' }) => {
    wrapper = shallowMount(PackagePath, {
      propsData,
      directives: {
        GlTooltip: createMockDirective(),
      },
    });
  };

  const BASE_ICON = 'base-icon';
  const ROOT_LINK = 'root-link';
  const ROOT_CHEVRON = 'root-chevron';
  const ELLIPSIS_ICON = 'ellipsis-icon';
  const ELLIPSIS_CHEVRON = 'ellipsis-chevron';
  const LEAF_LINK = 'leaf-link';

  const findItem = name => wrapper.find(`[data-testid="${name}"]`);
  const findTooltip = () => getBinding(wrapper.element, 'gl-tooltip');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.each`
    path                  | hasTooltip | shouldExist                                                   | shouldNotExist
    ${'foo'}              | ${false}   | ${[]}                                                         | ${[ROOT_CHEVRON, ELLIPSIS_ICON, ELLIPSIS_CHEVRON, LEAF_LINK]}
    ${'foo/bar'}          | ${false}   | ${[ROOT_CHEVRON, LEAF_LINK]}                                  | ${[ELLIPSIS_ICON, ELLIPSIS_CHEVRON]}
    ${'foo/bar/baz'}      | ${true}    | ${[ROOT_CHEVRON, LEAF_LINK, ELLIPSIS_ICON, ELLIPSIS_CHEVRON]} | ${[]}
    ${'foo/bar/baz/baz2'} | ${true}    | ${[ROOT_CHEVRON, LEAF_LINK, ELLIPSIS_ICON, ELLIPSIS_CHEVRON]} | ${[]}
  `('given path $path', ({ path, shouldExist, shouldNotExist, hasTooltip }) => {
    const pathPieces = path.split('/');

    beforeEach(() => {
      mountComponent({ path });
    });

    it('should have a base icon', () => {
      expect(findItem(BASE_ICON).exists()).toBe(true);
    });

    it('should have a root link', () => {
      const root = findItem(ROOT_LINK);
      expect(root.exists()).toBe(true);
      expect(root.attributes('href')).toBe(`/${pathPieces[0]}`);
    });

    it('should have a tooltip', () => {
      const tooltip = findTooltip();
      expect(tooltip).toBeDefined();
      expect(tooltip.value).toMatchObject({
        title: path,
        disabled: !hasTooltip,
      });
    });

    if (shouldExist.length > 0) {
      it.each(shouldExist)(`should have %s`, element => {
        expect(findItem(element).exists()).toBe(true);
      });
    }

    if (shouldNotExist.length > 0) {
      it.each(shouldNotExist)(`should not have %s`, element => {
        expect(findItem(element).exists()).toBe(false);
      });
    }

    if (shouldExist.includes(LEAF_LINK)) {
      it('the last link should be the last piece of the path', () => {
        const leaf = findItem(LEAF_LINK);
        expect(leaf.attributes('href')).toBe(`/${path}`);
        expect(leaf.text()).toBe(pathPieces[pathPieces.length - 1]);
      });
    }
  });
});
