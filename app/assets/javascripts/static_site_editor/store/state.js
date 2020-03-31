import { UNINITIALIZED } from '../constants';

const createState = (initialState = {}) => ({
  projectId: null,
  sourcePath: null,

  status: UNINITIALIZED,

  content: '',
  title: '',

  ...initialState,
});

export default createState;
