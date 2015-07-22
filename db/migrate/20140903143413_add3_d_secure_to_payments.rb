class Add3DSecureToPayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :md, :string
    add_column :spree_payments, :acs_url, :string
    add_column :spree_payments, :pareq, :text
    add_column :spree_payments, :vpstx_id, :string
    add_column :spree_payments, :security_key, :string
    add_column :spree_payments, :txauth_no, :string
  end
end

