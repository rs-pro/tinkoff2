module Tinkoff
  class Notification
    def initialize(params)
      @data = params.permit('TerminalKey',
                           'OrderId',
                           'Success',
                           'Status',
                           'PaymentId',
                           'ErrorCode',
                           'Amount',
                           'RebillId',
                           'CardId',
                           'Pan',
                           'Token',
                           'ExpDate',
                           'DATA').to_h
      @token_ok = authentic?
    end

    def get(key)
      @data[key]
    end

    def success?
      @token_ok && @data['Success'] == true
    end

    def failure?
      !success?
    end

    def payment_confirmed?
      @token_ok && success? && @data['Status'] == 'CONFIRMED'
    end

    # true - if token is okay, false - otherwise
    # https://oplata.tinkoff.ru/landing/develop/notifications/tokens
    def authentic?
      values = @data.except('Token').merge({Password: Tinkoff.tinkoff_params[:Password]})
                 .stringify_keys.sort.to_h.values.join
      get('Token') == Digest::SHA256.hexdigest(values)
    end
  end
end
