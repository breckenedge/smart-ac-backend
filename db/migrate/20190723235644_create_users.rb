class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :forename
      t.string :surname
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest
      t.boolean :locked, null: false, default: false

      t.timestamps
    end
  end
end
