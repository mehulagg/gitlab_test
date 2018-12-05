// Component documentation
export { default as GlChart } from '../components/charts/chart/chart.documentation';
export {
  default as GlSkeletonLoadingDocumentation,
} from '../components/base/skeleton_loading/skeleton_loading.documentation';
export { default as GlButtonDocumentation } from '../components/base/button/button.documentation';
export { default as GlLinkDocumentation } from '../components/base/link/link.documentation';
export {
  default as GlLoadingIconDocumentation,
} from '../components/base/loading_icon/loading_icon.documentation';
export { default as GlModalDocumentation } from '../components/base/modal/modal.documentation';
export {
  default as GlPaginationDocumentation,
} from '../components/base/pagination/pagination.documentation';
export {
  default as GlPopoverDocumentation,
} from '../components/base/popover/popover.documentation';
export {
  default as GlProgressBarDocumentation,
} from '../components/base/progress_bar/progress_bar.documentation';
export {
  default as GlTooltipDocumentation,
} from '../components/base/tooltip/tooltip.documentation';

const componentList = Object.getPrototypeOf(module).exports;

export const getDocumentationFor = componentName => {
  const documentationKey = `${componentName}Documentation`;
  const documentationObject = componentList[documentationKey];
  if (!documentationObject) {
    throw new Error(
      `Could not find ${documentationKey} in documentation/components_documentation.js!`
    );
  }
  return documentationObject;
};
