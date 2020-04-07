# frozen_string_literal: true

module AfterNextHelpers
  def allow_next(klass, to_receive:, returning: nil)
    allow_next_instance_of(klass) do |instance|
      allow(instance).to receive(to_receive).and_return(returning)
    end
  end

  def expect_next(klass, to_receive: nil, not_to_receive: nil, returning: nil, times: nil, with: nil)
    if to_receive
      expect_next_instance_of(klass) do |instance|
        expectation = receive(to_receive).and_return(returning)
        expectation = expectation.with(*with) if with
        expectation = expectation.exactly(times).times if times
        expect(instance).to expectation
      end
    end

    if not_to_receive
      allow_next_instance_of(klass) do |instance|
        expect(instance).not_to receive(not_to_receive)
      end
    end
  end

  def expect_service(klass)
    expect_next(klass, to_receive: :execute, returning: true)
  end
end
