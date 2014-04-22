require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should respond to name" do
    user=users(:one)
    assert_respond_to(user, :name)
  end
  test "should respond to email" do
    user=users(:one)
    assert_respond_to(user, :email)
  end

  test "should respond to address" do
    user=users(:one)
    assert_respond_to(user, :address)
  end

  test "should respond to password_digest" do
    user=users(:one)
    assert_respond_to(user, :password_digest)
  end

  test "should respond to password" do
    user=users(:one)
    assert_respond_to(user, :password)
  end

  test "should respond to password_confirmation" do
    user=users(:one)
    assert_respond_to(user, :password_confirmation)
  end

  test "should not allow the same email address twice" do
    user=users(:one)
    new_user=user.dup
    assert_not new_user.valid?
  end

  test "should not allow blank email address" do
    user=User.new(valid.except(:email))
    assert_not user.valid?
  end

  test "should not allow invalid email addresses" do
    bad_emails=%w(badmail bad@bad+com bad@bad,com @bad.com)
    assert_not bad_emails.any?{ |e| User.new(valid.merge(email: e)).valid? }
  end

  test "should not allow blank name" do
    user=User.new(valid.except(:name))
    assert_not user.valid?
  end

  test "should downcase email addresses" do
    user=User.new(valid)
    user.email="BAD@eMAil.com"
    assert user.save
    user.reload
    assert_equal "bad@email.com", user.email 
  end

  test "should be valid" do
    user=User.new(valid)
    assert user.valid?
  end

  test "should be invalid when password and confirmation mismatches" do
    user=User.new(valid.merge(password_confirmation: "Something else"))
    assert_not user.valid?
  end

  test "should not allow short password" do
    user=User.new(valid)
    user.password="short"
    user.password_confirmation="short"
    assert_not user.valid?
  end

  test "should be a User" do
    user=User.first
    assert user.is_a? User
  end

  test "should respond to orders" do
    user=User.new
    assert_respond_to user, :orders
  end

  test "should respond to carts" do
    user=User.new
    assert_respond_to user, :carts
  end

  test "should not validate password when existing object" do
    user=users(:buyer)
    assert_nil user.password
    assert user.valid?
  end

  test "should validate password when new one being set" do
    user=users(:buyer)
    assert user.valid?
    user.password="sh"
    user.password_confirmation="sh"
    assert_not user.valid?, "Debug: #{user.inspect}"
  end

  test "should change password" do
    user=User.create(valid)
    assert_equal user, user.authenticate(valid[:password])
    user.password="new password"
    user.password_confirmation="new password"
    user.save
    user=nil
    user=User.find_by(email: valid[:email])
    assert_not_equal user, user.authenticate(valid[:password])
    assert_equal user, user.authenticate("new password")
  end

  test "should not change password when confirmation blank" do
    user=User.create(valid)
    assert_equal user, user.authenticate(valid[:password])
    user.password="new password"
    user.password_confirmation=""
    assert_not user.save
  end

  test "should not change password when confirmation nil" do
    user=User.create(valid)
    assert_equal user, user.authenticate(valid[:password])
    user.password="new password"
    user.password_confirmation=nil
    assert_not user.save
  end

  test "should not change password when password is blank" do
    user=users(:buyer)
    user.password="    "
    user.password_confirmation=user.password
    assert_not user.valid?, "Debug: #{user.inspect}"
  end




  private
    def valid
      {name: "Test user", email: "test@test.com", address: "Where I live", password: "foobar", password_confirmation: "foobar"}
    end
end
