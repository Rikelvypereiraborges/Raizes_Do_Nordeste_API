class ServiceResult < Struct.new(:record, :errors, :status, keyword_init: true)
  def success?
    errors.blank?
  end
end
