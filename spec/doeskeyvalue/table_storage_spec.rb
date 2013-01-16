# AWEXOME LABS
# DoesKeyValue Test Suite : Table Storage

# Get started:
#require File.expand_path(File.dirname(__FILE__)+"/../spec_helper")

# Create schema for sample User model for testing column-based storage:
ActiveRecord::Base.connection.drop_table(:posts) if ActiveRecord::Base.connection.table_exists?(:posts)
ActiveRecord::Base.connection.create_table(:posts) do |t|
  t.integer :user_id
  t.string :title
  t.text :body
  t.timestamps
end

# Build the generator-style key value index table:
ActiveRecord::Base.connection.drop_table(:post_preferences) if ActiveRecord::Base.connection.table_exists?(:post_preferences)
ActiveRecord::Base.connection.create_table(:post_preferences) do |t|
  t.string :obj_type
  t.integer :obj_id
  t.string :key_name
  t.string :key_type
  t.string :value_string
  t.integer :value_integer
  t.decimal :value_decimal
  t.boolean :value_boolean
  t.datetime :value_datetime
  t.timestamps
end


# Define the sample Post model which will exhibit table-based storage:
class Post < ActiveRecord::Base
  attr_accessible :user_id, :title, :body
  belongs_to :user

  # Key-Value storage:
  does_keys :table=>"post_preferences"
  has_key :string_key
  has_key :integer_key, :type=>:integer
  has_key :decimal_key, :type=>:decimal
  has_key :bool_key, :type=>:boolean
  has_key :date_key, :type=>:datetime
  has_key :default_val_key, :default=>"The Default"
  has_key :indexless_key, :index=>false
end


# Test the ColumnStorage Module against the sample User class
describe "table_storage" do

  before(:each) do
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.begin_db_transaction
    @post = Post.new
    @post.save
  end

  after(:each) do
    ActiveRecord::Base.connection.rollback_db_transaction
    ActiveRecord::Base.connection.decrement_open_transactions
  end

  it "defines key read accessors" do
    %w(string_key integer_key decimal_key bool_key date_key default_val_key indexless_key).each do |key_name|
      @post.respond_to?( key_name.to_sym )
      @post.methods.include?( key_name.to_sym ).should be_true
    end
  end

  it "defines key write accessors" do
    %w(string_key integer_key decimal_key bool_key date_key default_val_key indexless_key).each do |key_name|
      @post.respond_to?( "#{key_name}=".to_sym )
      @post.methods.include?( "#{key_name}=".to_sym ).should be_true
    end
  end

  it "returns default value if none defined" do
    @post.default_val_key.should == "The Default"
  end

  it "saves and returns the same value for keys" do
    @post.string_key = "Ron Swanson"
    @post.save
    @post.reload
    @post.string_key.should == "Ron Swanson"
  end

  it "sets a string value when assigned" do
    @post.string_key = "Hello"
    @post.string_key.should == "Hello"
  end

  it "sets an integer value when assigned" do
    @post.integer_key = 123
    @post.integer_key.should == 123
    @post.integer_key.class.should == Fixnum
  end

  it "sets a decimal value when assigned" do
    @post.decimal_key = 12.21
    @post.decimal_key.should == 12.21
    # DB implementation dependent: @post.decimal_key.class.should == Float
  end

  it "sets a boolean value when assigned" do
    @post.bool_key = true
    @post.bool_key.should be_true
    @post.bool_key = false
    @post.bool_key.should be_false
  end

  it "sets a datetime value when assigned" do
    d0 = Time.now
    @post.date_key = d0
    @post.date_key.should == d0
  end

  it "defines with_ scope for indexed keys" do
    %w(string_key integer_key decimal_key bool_key date_key default_val_key).each do |key_name|
      User.methods.include?("with_#{key_name}".to_sym).should be_true
    end
  end

  it "does not define with_ scope for non-indexed keys" do
    User.methods.include?(:with_indexless_key).should be_false
  end

  it "finds objects via the scope and index" do
    @post.string_key = "Champion"
    @post.save
    find_results = Post.with_string_key("Champion")
    find_results.count.should == 1
    find_results.first.should == @post
  end

end # column_stage


