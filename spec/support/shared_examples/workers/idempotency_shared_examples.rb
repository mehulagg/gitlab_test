# frozen_string_literal: true

# This shared_example requires the following variables:
# - job_args
#
RSpec.shared_examples 'can handle multiple calls without raising exceptions' do
  # Avoid stubbing calls for a more accurate run.
  #
  it 'performs multiple times sequentially without raising an exception' do
    expect do
      defined?(job_args) ? perform_multiple(job_args) : perform_multiple
    end.not_to raise_error
  end
end
