import Vue from 'vue';
import PackageDetails from './components/package_details.vue';
import Translate from '~/vue_shared/translate';

Vue.use(Translate);

export default () =>
  new Vue({
    el: '#js-vue-packages-detail',
    components: {
      PackageDetails,
    },
    data() {
      const { dataset } = document.querySelector(this.$options.el);
      const packageData = JSON.parse(dataset.package);
      const packageFiles = JSON.parse(dataset.packageFiles);
      const canDelete = dataset.canDelete === 'true';

      return {
        packageData,
        packageFiles,
        canDelete,
        destroyPath: dataset.destroyPath,
        emptySvgPath: dataset.svgPath,
      };
    },
    render(createElement) {
      return createElement('package-details', {
        props: {
          packageEntity: this.packageData,
          files: this.packageFiles,
          canDelete: this.canDelete,
          destroyPath: this.destroyPath,
          emptySvgPath: this.emptySvgPath,
        },
      });
    },
  });
