export const trace = state => state.logs.lines.join('\n');

export const table = state => state.logs.lines.map((line) => ({'log message': line}));

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
