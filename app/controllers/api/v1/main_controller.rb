module Api
  module V1
    class MainController < ApplicationController
      def settle_transaction
        needed_params = {
          amount: params[:amount].to_i,
          credit_card_num: %w(credit_card number).reduce(params){|p,k| p && p[k]},
          credit_card_expiry: %w(credit_card expiry).reduce(params){|p,k| p && p[k]}
        }

        transaction = Transaction.new(needed_params)
        error_msg = transaction.detect_errors
        if error_msg.present?
          return(render json: { status: 406, message: "#{error_msg}" })
        end

        transaction_logger = Logger.new('log/transaction.log')
        transaction_logger.info("transaction_sending_to_creditcard_company time:#{Time.now} params:#{needed_params}")

        xml = transaction.parse_params_to_xml
        res = post_request(xml)

        transaction_logger.info("response_from_creditcard_company time:#{Time.now} response:#{res}")

        res_code = %w(response code).reduce(res){|r,k| r && r[k]}
        render_json_result(res_code)
      end

      private

      def render_json_result(res)
        case res
        when '0'
          render json: { status: 200 }
        when '-1'
          render json: { status: 406, messages: 'this credit card is invalid.' }
        else
          render json: { status: 500, messages: 'server error.' }
        end
      end

      def post_request(xml)
        uri = URI.parse 'https://aqueous-thicket-7667.herokuapp.com/charges'
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.post(uri.path, xml, {'Content-Type' =>'text/xml'})
        end
        res = Hash.from_xml(res.body)
      end
    end
  end
end
