export const variantOptions = {
  primary: 'primary',
  secondary: 'secondary',
  success: 'success',
  warning: 'warning',
  danger: 'danger',
  info: 'info',
  light: 'light',
  dark: 'dark',
};

export const variantOptionsWithNoDefault = Object.assign({}, variantOptions, {
  default: '',
});

export const targetOptions = {
  self: '_self',
  blank: '_blank',
  parent: '_parent',
  top: '_top',
  'null': '',
};
