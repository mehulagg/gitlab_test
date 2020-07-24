import AxiosMockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import { useSmartResource } from './resource';

// eslint-disable-next-line import/prefer-default-export
export const useAxiosMockAdapter = (axiosInstance = axios) =>
  useSmartResource(() => new AxiosMockAdapter(axiosInstance), mock => mock.restore());
