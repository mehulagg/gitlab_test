import $ from 'jquery';
import MockAdapter from 'axios-mock-adapter';
import '~/commons/bootstrap';
import axios from '~/lib/utils/axios_utils';
import Sidebar from '~/right_sidebar';
import { globalOn } from '~/helpers/global_event_hub';

let $aside = null;
let $toggle = null;
let $icon = null;
let $page = null;
let $labelsIcon = null;

const assertSidebarState = state => {
  const shouldBeExpanded = state === 'expanded';
  const shouldBeCollapsed = state === 'collapsed';
  expect($aside.hasClass('right-sidebar-expanded')).toBe(shouldBeExpanded);
  expect($page.hasClass('right-sidebar-expanded')).toBe(shouldBeExpanded);
  expect($icon.hasClass('fa-angle-double-right')).toBe(shouldBeExpanded);
  expect($aside.hasClass('right-sidebar-collapsed')).toBe(shouldBeCollapsed);
  expect($page.hasClass('right-sidebar-collapsed')).toBe(shouldBeCollapsed);
  expect($icon.hasClass('fa-angle-double-left')).toBe(shouldBeCollapsed);
};

describe('RightSidebar', () => {
  describe('fixture tests', () => {
    const fixtureName = 'issues/open-issue.html';
    preloadFixtures(fixtureName);
    let mock;

    beforeEach(() => {
      loadFixtures(fixtureName);
      mock = new MockAdapter(axios);
      new Sidebar(); // eslint-disable-line no-new
      $aside = $('.right-sidebar');
      $page = $('.layout-page');
      $icon = $aside.find('i');
      $toggle = $aside.find('.js-sidebar-toggle');
      $labelsIcon = $aside.find('.sidebar-collapsed-icon');
    });

    afterEach(() => {
      mock.restore();
    });

    it('should expand/collapse the sidebar when arrow is clicked', () => {
      assertSidebarState('expanded');
      $toggle.click();
      assertSidebarState('collapsed');
      $toggle.click();
      assertSidebarState('expanded');
    });

    it('should float over the page and when sidebar icons clicked', () => {
      $labelsIcon.click();
      assertSidebarState('expanded');
    });

    it('should collapse when the icon arrow clicked while it is floating on page', () => {
      $labelsIcon.click();
      assertSidebarState('expanded');
      $toggle.click();
      assertSidebarState('collapsed');
    });

    it('should broadcast todo:toggle event when add todo clicked', done => {
      const todos = getJSONFixture('todos/todos.json');
      mock.onPost(/(.*)\/todos$/).reply(200, todos);

      globalOn('todo:toggle', count => {
        expect(count).toEqual(2);
        done();
      });

      $('.issuable-sidebar-header .js-issuable-todo').click();
    });

    it('should not hide collapsed icons', () => {
      [].forEach.call(document.querySelectorAll('.sidebar-collapsed-icon'), el => {
        expect(el.querySelector('.fa, svg').classList.contains('hidden')).toBeFalsy();
      });
    });
  });
});
