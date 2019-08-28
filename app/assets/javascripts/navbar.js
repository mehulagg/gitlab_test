import $ from 'jquery';

const COLLAPSED_CLASS = 'navbar-collapsed';

export default function setupCollapsibleNavbar({
  autoCollapse = false,
  autoCollapseTimeout = 3000,
}) {
  const navbar = $('.navbar-collapsible');
  const trigger = $('.navbar-collapse-trigger');

  if (!navbar[0]) {
    return;
  }

  // have to declare functions before hand :/
  let collapse;

  const expand = () => {
    navbar.removeClass(COLLAPSED_CLASS);
    trigger.off('click', expand);

    // Temporary hack to keep the mouseleave from triggering after the navbar is shown :/
    setTimeout(() => {
      navbar.on('mouseleave', collapse);
    }, 500);
  };
  collapse = () => {
    navbar.addClass(COLLAPSED_CLASS);
    navbar.off('mouseleave', collapse);
    trigger.on('click', expand);
  };

  // init setup
  if (autoCollapse) {
    setTimeout(() => {
      collapse();
    }, autoCollapseTimeout);
  }
}
