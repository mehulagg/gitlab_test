# frozen_string_literal: true

module NonExistingRecordsHelpers
  ACTIVE_MODEL_INTEGER_MAX = 1 << (4 * 8 - 1) # 8 bits per byte with one bit for sign

  def non_existing_record_id(model: nil)
    non_existing_record_attr(model: model, attr: :id)
  end

  def non_existing_record_iid(model: nil)
    non_existing_record_attr(model: model, attr: :iid)
  end

  def non_existing_record_attr(model: nil, attr: :id)
    if model
      (model.maximum(attr) || 0) + 1
    else
      ACTIVE_MODEL_INTEGER_MAX
    end
  end
end
