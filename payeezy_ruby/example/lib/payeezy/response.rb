module Payeezy
  class Response
    Struct.new("Token", :token_type, :token_data)
    Struct.new("Card", :type, :cardholder_name, :card_number, :exp_date)

    RESPONSE_FIELDS = [
      :correlation_id, :transaction_status, :validation_status,
      :transaction_type, :transaction_id, :transaction_tag, :method,
      :amount, :currency, :cvv2, :token, :card,
      :gateway_resp_code, :gateway_message,

      :bank_response,

      :errors,

      :raw_response
    ]

    attr_accessor *RESPONSE_FIELDS

    def initialize(raw_response)
      begin
        @raw_response = JSON.parse(raw_response)
      rescue JSON::ParserError
      end

      @errors = []

      process_response
    end

    def [](key)
      @raw_response[key]
    end

    def success?
      !validation_error? && bank_response.success?
    end

    def validation_error?
      validation_status != "success"
    end

    def bank_error?
      !bank_response.success?
    end

    private

    def process_response
      raw = @raw_response
      if raw["bank_resp_code"]
        self.bank_response = Payeezy::BankResponse.new(
          raw.delete("bank_resp_code"),
          raw.delete("bank_message")
        )
      end

      raw.each do |key, value|
        case key
        when "token"
          @token = Struct::Token.new(value["token_type"], value["token_data"]["value"])
        when "Error"
          @errors = value["messages"].collect do |msg|
            Payeezy::ValidationError.new(msg["code"], msg["description"])
          end
        else
          instance_variable_set(:"@#{key.downcase}", value)
        end
      end
    end
  end
end
