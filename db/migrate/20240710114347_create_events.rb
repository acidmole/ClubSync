class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events, id: false do |t|
      t.integer :id, primary_key: true
      t.string :name
      t.string :venue
      t.datetime :starts_at

      t.timestamps
    end

    add_index :events, :id, unique: true
  end
end
