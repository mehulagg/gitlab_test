import * as components from '../index';
import * as chartComponents from '../charts';

export const gitlabComponents = { ...components, ...chartComponents };

export const componentValidator = componentName =>
  Object.keys(gitlabComponents).includes(componentName);
