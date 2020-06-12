# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Redis::BigKeys, :clean_gitlab_redis_shared_state do
  describe '#report' do
    subject { test_redis { |redis| described_class.new(redis).report } }

    def test_redis
      Gitlab::Redis::SharedState.with { |redis| yield redis }
    end

    it 'creates a report' do
      test_redis do |redis|
        redis.set('mystring', 'foobar')
        redis.set('bigstring', 'hello' * 100)

        redis.lpush('mylist', 'foobar')
        redis.lpush('biglist', Array.new(100) { 'foobar' })
        redis.lpush('memlist', Array.new(10) { 'foobar' * 100 })

        redis.sadd('myset', 'foobarx')
        redis.sadd('bigset', Array.new(101) { |i| "foobar#{i.chr}" })
        redis.sadd('memset', 'foobarx' * 1000)

        redis.zadd('myzset', [1, 'foobarxx'])
        redis.zadd('bigzset', Array.new(102) { |i| [i, "foobarx#{i.chr}"] }.flatten)
        redis.zadd('memzset', [1, 'foobarxx' * 1000])
      end

      expected = {
        biggest: {
          by_elements: {
            string: { key: 'bigstring', elements: 500 },
            list: { key: 'biglist', elements: 100 },
            set: { key: 'bigset', elements: 101 },
            zset: { key: 'bigzset', elements: 102 }
          },
          by_bytes: {
            string: { key: 'bigstring', bytes: 500 },
            list: { key: 'memlist', bytes: 6000 },
            set: { key: 'memset', bytes: 7000 },
            zset: { key: 'memzset', bytes: 8000 }
          }
        },
        summary: {
          string: {
            sampled_count: 2,
            total_elements: 506,
            total_bytes: 506
          },
          list: {
            sampled_count: 3,
            total_elements: 111,
            total_bytes: 6606
          },
          set: {
            sampled_count: 3,
            total_elements: 103,
            total_bytes: 7707
          },
          zset: {
            sampled_count: 3,
            total_elements: 104,
            total_bytes: 8824
          },
          hash: {
            sampled_count: 0,
            total_elements: 0,
            total_bytes: 0
          },
          stream: {
            sampled_count: 0,
            total_elements: 0,
            total_bytes: 0
          }
        }
      }

      actual = subject

      expect(actual[:biggest][:by_elements]).to eq(expected[:biggest][:by_elements])

      expect(actual[:biggest][:by_bytes].keys.sort).to eq(expected[:biggest][:by_bytes].keys.sort)

      expected[:biggest][:by_bytes].each do |type, hash|
        expect(actual[:biggest][:by_bytes][type][:key]).to eq(hash[:key])

        # The number returned by MEMORY USAGE includes administrative overhead we cannot
        # predict, so we cannot say 'eq' here.
        expect(actual[:biggest][:by_bytes][type][:bytes]).to be >= hash[:bytes]
      end

      expect(actual[:summary].keys.sort).to eq(expected[:summary].keys.sort)

      expected[:summary].each do |type, hash|
        hash.each do |key, value|
          if key == :total_bytes
            expect(actual[:summary][type][key]).to be >= value
          else
            expect(actual[:summary][type][key]).to eq(value)
          end
        end
      end
    end
  end
end
