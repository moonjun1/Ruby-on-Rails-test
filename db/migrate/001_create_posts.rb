class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.boolean :published, default: false, null: false
      t.timestamps
    end

    add_index :posts, :published
    add_index :posts, :created_at
    add_index :posts, [:published, :created_at], name: 'index_posts_on_published_and_created_at'
  end
end