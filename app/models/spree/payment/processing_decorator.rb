module Spree
  Spree::Payment.class_eval do

    def is_3d_secure?
      self.md? and !self.txauth_no?
    end

    private

    alias_method :spree_handle_response, :handle_response

    def handle_response(response, success_state, failure_state)
      if response.params['Status'].eql? '3DAUTH'
        self.update_columns(
          md: response.params['MD'],
          acs_url: response.params['ACSURL'],
          pareq: response.params['PAReq']
        )
        gateway_error(response)
      else
        spree_handle_response(response, success_state, failure_state)
      end
    end
  end
end
