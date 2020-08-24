import $ from 'jquery';
import NotificationsForm from '../../../../notifications_form';
import notificationsDropdown from '../../../../notifications_dropdown';

document.addEventListener('DOMContentLoaded', () => {
  new NotificationsForm(); // eslint-disable-line no-new
  notificationsDropdown();

  function toggleTab(e) {
    const target = $(e.currentTarget).data("target");
    const href = $(e.currentTarget).data("href");

    $.ajax({
      type: "GET",
      url: href,
      data: {tab: target},
      dataType: "script"
    }).done(function (data) {
      $('.tab-pane.active').html(data);
    });
  };

  $('.notification_tabs > li > a[data-toggle="tab"]').on('shown.bs.tab', toggleTab);
});
