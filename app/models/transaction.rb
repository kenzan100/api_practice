class Transaction
  def initialize(params)
    @amount = params[:amount]
    @credit_card_num = params[:credit_card_num]
    @credit_card_expiry = params[:credit_card_expiry]
    @needed_params = params
  end

  def detect_errors
    missing_params = @needed_params.select{|_k,v| v.nil?}
    missing_params_msg  = missing_params.present? ? "missing_params. #{missing_params.keys.join(',')}" : nil
    return missing_params_msg unless missing_params_msg.nil?

    amount_out_of_range = !@amount.between?(100, 10000) ? "amount needs to be within 100~10000." : nil
    expiry_wrong_format = @credit_card_expiry.match(/\d{4}-\d{2}-\d{2}/).nil? ? "wrong expiry format." : nil
    year, month, day    = @credit_card_expiry.split('-').map(&:to_i)
    expiry_invalid_date = expiry_wrong_format.nil? && !Date.valid_date?(year,month,day) ? "invalid date." : nil

    [missing_params_msg, amount_out_of_range, expiry_wrong_format, expiry_invalid_date].compact.join(' | ')
  end

  def parse_params_to_xml
    year, month = @credit_card_expiry.split('-').map(&:to_i)
    build_xml(year.to_s.split('')[2..3].join, month.to_s.rjust(2,'0'))
  end

  def build_xml(expiry_yy, expiry_mm)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, encoding: "UTF-8"
    xml.credit_card do
      xml.number(@credit_card_num)
      xml.expire_yy(expiry_yy)
      xml.expire_mm(expiry_mm)
    end
  end
end
