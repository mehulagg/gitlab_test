# frozen_string_literal: true

require 'spec_helper'

class FakeLogger
end

class LoggerA < Gitlab::Logger
  def self.file_name_noext
    'loggerA'
  end
end

class LoggerB < Gitlab::Logger
  def self.file_name_noext
    'loggerB'
  end
end

class TestLogger < Gitlab::MultiDestinationLogger
  def self.loggers
    [LoggerA, LoggerB]
  end
end

class EmptyLogger < Gitlab::MultiDestinationLogger
  def self.loggers
    []
  end
end

describe Gitlab::MultiDestinationLogger do
  context 'with no loggers set' do
    subject { EmptyLogger }

    it 'primary_logger is nil' do
      expect(subject.primary_logger).to be_nil
    end
  end

  context 'with 2 loggers set' do
    subject { TestLogger }

    it 'selects the first logger as the primary logger' do
      expect(subject.primary_logger).to be(LoggerA)
    end

    it 'logs info to 2 loggers' do
      expect(LoggerA).to receive(:build).and_call_original
      expect(LoggerB).to receive(:build).and_call_original

      subject.info('hello world')
    end

    context 'when reading latest logs' do
      context 'when the specified logger is not included in the class' do
        it 'raises an error' do
          expect { subject.read_latest(FakeLogger) }.to raise_error(Gitlab::InvalidLogger)
        end
      end
    end
  end
end
