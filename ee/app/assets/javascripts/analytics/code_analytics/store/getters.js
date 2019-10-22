import httpStatus from '~/lib/utils/http_status';

// eslint-disable-next-line import/prefer-default-export
export const hasNoAccessError = state => state.errorCode === httpStatus.FORBIDDEN;
