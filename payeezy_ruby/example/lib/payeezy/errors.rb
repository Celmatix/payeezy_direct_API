module Payeezy
  class Error < Struct
  end

  class ValidationError < Error.new(:code, :description)
  end

  class BankError < Error.new(:code, :message)
  end
end
