# frozen_string_literal: true

class ServiceResponse
  class Success < ServiceResponse
  end

  class Error < ServiceResponse
  end

  def self.success(message: nil, payload: {}, http_status: :ok)
    self::Success.new(status: :success, message: message, payload: payload, http_status: http_status)
  end

  def self.error(message:, payload: {}, http_status: nil)
    self::Error.new(status: :error, message: message, payload: payload, http_status: http_status)
  end

  attr_reader :status, :message, :http_status, :payload

  def initialize(status:, message: nil, payload: {}, http_status: nil)
    self.status = status
    self.message = message
    self.payload = payload
    self.http_status = http_status
  end

  def success?
    status == :success
  end

  def error?
    status == :error
  end

  def to_h
    { status: status, message: message, http_status: http_status, payload: payload }
  end

  def deconstruct_keys(keys)
    keys ? to_h.slice(*keys) : to_h
  end

  private

  attr_writer :status, :message, :http_status, :payload
end
