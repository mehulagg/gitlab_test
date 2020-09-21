import $ from 'jquery';
import '~/lib/utils/jquery_at_who';
import axios from '~/lib/utils/axios_utils';
import GfmAutoComplete from '~/gfm_auto_complete';

/**
 * This is added to keep the export parity with the CE counterpart.
 *
 * Some modules import `defaultAutocompleteConfig` or `membersBeforeSave`
 * which will be undefined if not exported from here in EE.
 */
export { defaultAutocompleteConfig, membersBeforeSave } from '~/gfm_auto_complete';

class GfmAutoCompleteEE extends GfmAutoComplete {
  setupAtWho($input) {
    if (this.enableMap.epics) {
      this.setupAutoCompleteEpics($input, this.getDefaultCallbacks());
    }

    if (this.enableMap.vulnerabilities) {
      this.setupAutoCompleteVulnerabilities($input, this.getDefaultCallbacks());
    }

    super.setupAtWho($input);
  }

  setupAutoCompleteEpics = ($input, defaultCallbacks) => {
    $input.atwho({
      at: '&',
      alias: 'epics',
      searchKey: 'search',
      displayTpl(value) {
        let tmpl = GfmAutoComplete.Loading.template;
        if (value.title != null) {
          tmpl = GfmAutoComplete.Issues.templateFunction(value);
        }
        return tmpl;
      },
      data: GfmAutoComplete.defaultLoadingData,
      // eslint-disable-next-line no-template-curly-in-string
      insertTpl: '${atwho-at}${id}',
      callbacks: {
        ...defaultCallbacks,
        beforeSave(merges) {
          return $.map(merges, m => {
            if (m.title == null) {
              return m;
            }
            return {
              id: m.iid,
              title: m.title.replace(/<(?:.|\n)*?>/gm, ''),
              search: `${m.iid} ${m.title}`,
            };
          });
        },
      },
    });
  };

  fetchVulnerabilities = ($input, at, search) => {
    if (this.isLoadingData[at]) return;

    this.isLoadingData[at] = true;
    const dataSource = this.dataSources[GfmAutoComplete.atTypeMap[at]];

    if (dataSource) {
      axios.get(dataSource, { params: { search } })
        .then(({ data }) => {
          this.loadData($input, at, data);
        })
        .catch(() => {
          this.isLoadingData[at] = false;
        });
    } else {
      this.isLoadingData[at] = false;
    }
  };

  setupAutoCompleteVulnerabilities = ($input, defaultCallbacks) => {
    const fetchVulnerabilities = this.fetchVulnerabilities.bind(this);
    $input.atwho({
      at: '+',
      alias: 'vulnerabilities',
      searchKey: 'search',
      displayTpl(value) {
        let tmpl = GfmAutoComplete.Loading.template;
        if (value.title != null) {
          tmpl = GfmAutoComplete.Issues.templateFunction(value);
        }
        return tmpl;
      },
      data: GfmAutoComplete.defaultLoadingData,
      insertTpl: GfmAutoComplete.Issues.insertTemplateFunction,
      skipSpecialCharacterTest: true,
      callbacks: {
        ...defaultCallbacks,
        filter(query, data, searchKey) {
          if (GfmAutoComplete.isLoading(data) || this.previousQuery !== query) {
            fetchVulnerabilities(this.$inputor, this.at, query);
            this.previousQuery = query;
            return data;
          }
          return $.fn.atwho.default.callbacks.filter(query, data, searchKey);
        },
        beforeSave(merges) {
          return merges.map(m => {
            if (m.title == null) {
              return m;
            }
            return {
              id: m.id,
              title: m.title.replace(/<(?:.|\n)*?>/gm, ''),
              reference: m.reference,
              search: `${m.id} ${m.title}`,
            };
          });
        },
      },
    });
  };
}

export default GfmAutoCompleteEE;
