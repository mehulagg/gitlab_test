export const isSearchingProjects = ({ searchCount }) => searchCount > 0;

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
