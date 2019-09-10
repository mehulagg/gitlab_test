import { debounce } from 'underscore';
import axios from '~/lib/utils/axios_utils';

const USERNAME_SUGGEST_DEBOUNCE_TIME = 300;
const USERNAME_SUGGEST_API_PATH = '/-/username/suggestion';

export default class UsernameSuggesstor {
  /**
   * Creates an instance of UsernameSuggesstor.
   * @param {HTMLElement} targetElement target input element for suggested username
   * @param {HTMLElement[]} sourceElementsIds array of HTML input elements used for generating username
   */
  constructor(targetElement, sourceElementsIds = []) {
    this.username = document.getElementById(targetElement);
    this.sourceElements = [
      ...document.querySelectorAll(sourceElementsIds.map(id => `#${id}`).join(',')),
    ];
    this.isLoading = false;

    this.bindEvents();
  }

  bindEvents() {
    this.sourceElements.forEach(sourceElement => {
      sourceElement.addEventListener(
        'change',
        debounce(this.suggestUsername.bind(this), USERNAME_SUGGEST_DEBOUNCE_TIME),
      );
    });
  }

  suggestUsername() {
    if (this.isLoading) {
      return;
    }

    const name = this.joinSources();

    if (!name) {
      return;
    }

    axios
      .get(`${USERNAME_SUGGEST_API_PATH}?name=${name}`)
      .then(({ data }) => {
        this.username.value = data.username;
      })
      .catch(() => {})
      .finally(() => {
        this.isLoading = false;
      });
  }

  /**
   * Joins values from source elements to a string
   * separated by `_` (underscore)
   */
  joinSources() {
    return this.sourceElements
      .map(el => encodeURIComponent(el.value))
      .filter(Boolean)
      .join('_');
  }
}
