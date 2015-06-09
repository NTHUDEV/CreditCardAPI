class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.text :encrypted_number
      t.string :nonce
      t.string :owner
      t.string :expiration_date
      t.string :credit_network
      t.timestamps null: false
      t.integer :user_id
    end
  end
end
