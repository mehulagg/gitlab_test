import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import { parseBoolean } from '~/lib/utils/common_utils';
import { STEPS, TAX_RATE } from '../constants';

const parsePlanData = planData =>
  JSON.parse(planData).map(plan => ({
    value: plan.id,
    text: capitalizeFirstCharacter(plan.code),
    pricePerUserPerYear: plan.price_per_year,
  }));

const determineSelectedPlan = (planId, plans) => {
  if (planId && plans.find(plan => plan.value === planId)) {
    return planId;
  }
  return plans[0] && plans[0].value;
};

export default ({ planData = '[]', planId, setupForCompany, fullName, newUser }) => {
  const availablePlans = parsePlanData(planData);

  return {
    currentStep: STEPS[0],
    isSetupForCompany: parseBoolean(setupForCompany),
    availablePlans,
    selectedPlan: determineSelectedPlan(planId, availablePlans),
    newUser: parseBoolean(newUser),
    fullName,
    organizationName: null,
    numberOfUsers: parseBoolean(setupForCompany) ? 0 : 1,
    country: null,
    streetAddressLine1: null,
    streetAddressLine2: null,
    city: null,
    countryState: null,
    zipCode: null,
    countryOptions: [],
    stateOptions: [],
    paymentFormParams: {},
    paymentMethodId: null,
    creditCardDetails: {},
    isLoadingPaymentMethod: false,
    isConfirmingOrder: false,
    taxRate: TAX_RATE,
    startDate: new Date(Date.now()),
  };
};
