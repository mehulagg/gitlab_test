import { hexToRgb } from '~/lib/utils/color_utils';
import { green500, orange500, red500 } from '@gitlab/ui/scss_to_js/scss_variables';

export const DEFAULT_TILE_SIZE = 32;
export const DEFAULT_SPACING = 5;

const green = hexToRgb(green500);
const orange = hexToRgb(orange500);
const red = hexToRgb(red500);

const opacity = [0.2, 0.4, 0.6, 0.8];

export const DEFAULT_COLORS = [
  `rgba(${green}, ${opacity[0]})`,
  `rgba(${green}, ${opacity[1]})`,
  `rgba(${green}, ${opacity[2]})`,
  `rgba(${green}, ${opacity[3]})`,
  `rgba(${orange}, ${opacity[3]})`,
  `rgba(${red}, ${opacity[3]})`,
];
