module Payeezy
  class BankResponse < Struct.new(:code, :message)
    def status
      get_status
    end

    def success?
      status == "success"
    end

    private

    def get_status
      @status ||= case code.to_i
      when 0
        "declined"
      when 100..199
        "success"
      when 201..258, 261..274
        "rejected"
      when 260, 301..307
        "declined"
      end
    end
  end
end
