/* eslint-disable import/prefer-default-export */
import compose from 'lodash/fp/compose';
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';

const groupPageInfo = ({ page, nextPage, total, totalPages }) => ({
  pageInfo: { page, nextPage, total, totalPages },
});

const getHeaders = res => res.headers;

const pageInfo = compose(
  groupPageInfo,
  parseIntPagination,
  normalizeHeaders,
  getHeaders,
);

export const addPageInfo = res => ({ ...res, ...pageInfo(res) });
