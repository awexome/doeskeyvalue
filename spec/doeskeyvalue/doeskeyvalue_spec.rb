# AWEXOME LABS
# DoesKeyValue Test Suite

# Get started:
require File.expand_path(File.dirname(__FILE__)+"/../spec_helper")

# Create schema for sample User model for testing column-based storage:
ActiveRecord::Base.connection.drop_table(:users) if ActiveRecord::Base.connection.table_exists?(:users)
ActiveRecord::Base.connection.create_table(:users) do |t|
  t.string :name  
  t.string :email
  t.text :settings
  t.timestamps
end

# Build the generator-style key value index table:
ActiveRecord::Base.connection.drop_table(:key_value_index) if ActiveRecord::Base.connection.table_exists?(:key_value_index)
ActiveRecord::Base.connection.create_table(:key_value_index) do |t|
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


# Define the sample User model which will exhibit column-based storage:
class User < ActiveRecord::Base
  attr_accessible :name, :email, :settings
  has_many :posts

  # Key-Value storage:
  does_keys :column=>"settings"
  has_key :string_key
  has_key :integer_key, :type=>:integer
  has_key :decimal_key, :type=>:decimal
  has_key :bool_key, :type=>:boolean
  has_key :date_key, :type=>:datetime
  has_key :default_val_key, :default=>"The Default"
  has_key :indexless_key, :index=>false
end


# Test the ColumnStorage Module against the sample User class
describe "column_storage" do

  before(:each) do
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.begin_db_transaction
    @user = User.new
  end

  after(:each) do
    ActiveRecord::Base.connection.rollback_db_transaction
    ActiveRecord::Base.connection.decrement_open_transactions
  end

  it "defines key read accessors" do
    %w(string_key integer_key decimal_key bool_key date_key default_val_key indexless_key).each do |key_name|
      @user.respond_to?( key_name.to_sym )
      @user.methods.include?( key_name.to_sym ).should be_true
    end
  end

  it "defines key write accessors" do
    %w(string_key integer_key decimal_key bool_key date_key default_val_key indexless_key).each do |key_name|
      @user.respond_to?( "#{key_name}=".to_sym )
      @user.methods.include?( "#{key_name}=".to_sym ).should be_true
    end
  end

  it "returns default value if none defined" do
    @user.default_val_key.should == "The Default"
  end

  it "saves and returns the same value for keys" do
    @user.string_key = "Ron Swanson"
    @user.save
    @user.reload
    @user.string_key.should == "Ron Swanson"
  end

  it "sets a string value when assigned" do 
    @user.string_key = "Hello"
    @user.string_key.should == "Hello"
  end

  it "sets an integer value when assigned" do 
    @user.integer_key = 123
    @user.integer_key.should == 123
    @user.integer_key.class.should == Fixnum
  end
  
  it "sets a decimal value when assigned" do 
    @user.decimal_key = 12.21
    @user.decimal_key.should == 12.21
    @user.decimal_key.class.should == Float
  end
  
  it "sets a boolean value when assigned" do 
    @user.bool_key = true
    @user.bool_key.should be_true
    @user.bool_key = false
    @user.bool_key.should be_false
  end

  it "sets a datetime value when assigned" do 
    d0 = DateTime.now
    @user.date_key = d0
    @user.date_key.should == d0
    @user.date_key.class.should == DateTime
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
    @user.string_key = "Champion"
    @user.save
    find_results = User.with_string_key("Champion")
    find_results.length.should == 1
    find_results.first.should == @user
  end

end # column_stage


