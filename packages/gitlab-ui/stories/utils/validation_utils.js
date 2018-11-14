// Creates out of validation configurations from .documentation.js files and creates a readable string out of it
export const getValidationInfoText = (validation = {}) => {
  switch (validation.type) {
    case 'range':
      return `${validation.min}-${validation.max}`;
    default:
      return '';
  }
};

export default {};
