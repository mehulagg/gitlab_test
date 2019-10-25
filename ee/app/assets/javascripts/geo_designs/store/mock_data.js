import { __ } from '~/locale';

function generateRandomDateString() {
  return new Date(
    new Date(2019, 0, 1).getTime() +
      Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime()),
  ).toString();
}

const mockData = [
  {
    id: 1,
    name: __("Zack's Design Repo"),
    url: 'http://localhost:3002',
    sync_status: 'synced',
    last_synced_at: generateRandomDateString(),
    last_verified_at: generateRandomDateString(),
    last_checked_at: generateRandomDateString(),
  },
  {
    id: 2,
    name: __("Valery's Design Repo"),
    url: 'http://localhost:3002',
    sync_status: 'pending',
    last_synced_at: generateRandomDateString(),
    last_verified_at: generateRandomDateString(),
    last_checked_at: generateRandomDateString(),
  },
  {
    id: 3,
    name: __("Mike's Design Repo"),
    url: 'http://localhost:3002',
    sync_status: 'failed',
    last_synced_at: generateRandomDateString(),
    last_verified_at: generateRandomDateString(),
    last_checked_at: generateRandomDateString(),
  },
  {
    id: 4,
    name: __("Rachel's Design Repo"),
    url: 'http://localhost:3002',
    sync_status: null,
    last_synced_at: null,
    last_verified_at: null,
    last_checked_at: null,
  },
];

export default mockData;
