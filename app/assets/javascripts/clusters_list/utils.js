import { K8S_MEASUREMENTS } from './constants';

const convertK8sUnitToBaseValue = k8sQuantity => {
  const k8sType = K8S_MEASUREMENTS[k8sQuantity.replace(/[^a-zA-Z]/g, '')];

  if (k8sType) {
    const quantityNumber = parseInt(
      k8sQuantity.substr(0, k8sQuantity.length - k8sType.stringLength),
      10,
    );
    const k8sConvertValue = k8sType.base ** k8sType.exponent;

    return quantityNumber * k8sConvertValue;
  }

  // We are trying to track quantity types coming from Kubernetes.
  // Sentry will notify us if we are missing types.
  throw new Error(`UnknownK8sQuantity:${k8sQuantity}`);
};

const convertK8sQuantityToBaseValue = k8sQuantity => {
  if (!k8sQuantity) {
    return 0;
  }

  const baseValue = Number(k8sQuantity);

  return Number.isNaN(baseValue) ? convertK8sUnitToBaseValue(k8sQuantity) : baseValue;
};

export const calculatePercentage = (allocated, used) => {
  return Math.round((1 - used / allocated) * 100);
};

export const sumNodeCpuAndUsage = ({ allocated, used }, node) => ({
  allocated: allocated + convertK8sQuantityToBaseValue(node?.status?.allocatable?.cpu),
  used: used + convertK8sQuantityToBaseValue(node?.usage?.cpu),
});

export const sumNodeMemoryAndUsage = ({ allocated, used }, node) => {
  const Gigabyte = 1000000000.0;

  return {
    allocated:
      allocated + convertK8sQuantityToBaseValue(node?.status?.allocatable?.memory) / Gigabyte,
    used: used + convertK8sQuantityToBaseValue(node?.usage?.memory) / Gigabyte,
  };
};
