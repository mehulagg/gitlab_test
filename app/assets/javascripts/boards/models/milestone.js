export default class ListMilestone {
  constructor(obj) {
    this.id = obj.id;
    this.title = obj.title;

    if (IS_EE) {
      this.webUrl = obj.web_url || obj.webUrl;
      this.description = obj.description;
    }
  }
}

window.ListMilestone = ListMilestone;
