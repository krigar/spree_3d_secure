module Spree
  Spree::CheckoutController.class_eval do
    private
      def before_payment
        if @order.is_3d_secure?
          @payment = @order.payments.find(&:is_3d_secure?)
          @term_url = "#{request.base_url}/checkout/3dcallback"
          render :authenticate_3d_secure
        end
      end
  end
end
