import MockDate from 'mockdate';

// Frida Kahlo's birthday
export const DEFAULT_DATE = '2020-07-06';

export const useFakeDate = (date = DEFAULT_DATE) => {
  MockDate.set(date);
};

export const useRealDate = () => {
  MockDate.reset();
};
