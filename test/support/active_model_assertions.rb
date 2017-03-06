# frozen_string_literal: true
module ActiveModelAssertions
  def assert_valid(model, msg = nil)
    valid  = model.valid?
    errors = model.errors.full_messages.join(', ')
    msg    = message(msg) { "Expected #{model} to be valid, but got errors: #{errors}." }

    assert valid, msg
  end

  def refute_valid(model, msg = nil)
    valid  = model.valid?
    errors = model.errors.full_messages.join(', ')
    msg    = message(msg) { "Expected #{model} to be valid, but got errors: #{errors}." }

    refute valid, msg
  end
end
