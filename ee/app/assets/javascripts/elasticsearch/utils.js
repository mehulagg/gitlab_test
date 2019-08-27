export const fetchErrorData = resp => {
  return resp.data && resp.data.message;
};
