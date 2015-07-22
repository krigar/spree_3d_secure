module Spree
  class ThreeDSecureController < Spree::StoreController
    skip_before_filter :verify_authenticity_token, :only => :callback

    def callback
      order = current_order

      response = sagepay_response(Rails.application.config.three_d_secure_callback, params['MD'], params['PaRes'])
      response_hash = sagepay_response_to_hash(response)

      begin
        payment = Payment.find_by_md!(params['MD'])

        payment.update_columns(
          vpstx_id: response_hash['VPSTxId'],
          security_key: response_hash['SecurityKey'],
          txauth_no: response_hash['TxAuthNo']
        )

        if response_hash['Status'].eql? 'OK' and !response_hash['TxAuthNo'].empty?
          payment.send(:complete)

          # set these values to nil to comply with SagePay policy
          payment.update_columns(acs_url: nil, pareq: nil)
          
          # the order's payment total is used to verify the order's payment state when finalizing
          order.payment_total += payment.amount
          order.next

          if order.completed?
            flash.notice = Spree.t(:order_processed_successfully)
            flash[:order_completed] = true
            redirect_to order_path(order, :token => order.guest_token)
          else
            if order.errors.any?
              flash.error = order.errors.full_messages.inspect
            end

            redirect_to checkout_state_path(order.state)
          end
        else
          payment.send(:failure)

          # set these values to nil to comply with SagePay policy
          payment.update_columns(md: nil, acs_url: nil, pareq: nil)

          flash.error = response_hash['StatusDetail']
          redirect_to checkout_state_path(:payment)
        end
      rescue ActiveRecord::RecordNotFound
        flash.error = Spree.t(:payment_not_found)
        redirect_to checkout_state_path(:payment)
      end
    end

    private
      def sagepay_response(uri, md, pares)
        url = URI.parse(uri)
        req = Net::HTTP::Post.new(url.request_uri)
        req.set_form_data({'MD'=>md, 'PARes'=>pares})
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.request(req)
      end

      def sagepay_response_to_hash(response)
        response_formatted = response.body.to_s.gsub(/\r?\n/, ',')
        response_hash = {}
        response_formatted.split(',').each do |pair|
          key,value = pair.split('=')
          response_hash[key] = value
        end
        response_hash
      end
  end
end
