module Spree
  Spree::Order.class_eval do
    def is_3d_secure?
      payments.any?(&:is_3d_secure?)
    end
  end
end
