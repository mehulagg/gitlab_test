import axios from '~/lib/utils/axios_utils';
import {
  PAYMENT_FORM_ID,
  PAYMENT_FORM_URL,
  PAYMENT_METHOD_URL,
  CONFIRM_ORDER_URL,
  COUNTRIES_URL,
  STATES_URL,
} from './constants';

export const loadCountries = () => axios.get(COUNTRIES_URL).then(response => response.data || []);

export const loadStates = country =>
  axios.get(STATES_URL, { params: { country } }).then(response => response.data || {});

export const loadPaymentMethodDetails = id =>
  axios.get(PAYMENT_METHOD_URL, { params: { id } }).then(response => response.data);

export const loadPaymentFormParams = () =>
  axios.get(PAYMENT_FORM_URL, { params: { id: PAYMENT_FORM_ID } }).then(response => response.data);

export const postConfirmOrder = params =>
  axios.post(CONFIRM_ORDER_URL, params).then(response => response.data);
