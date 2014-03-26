require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test "should respond to user" do
    session=Session.new
    assert_respond_to session, :user
  end
  test "should respond to ip_addr" do
    session=Session.new
    assert_respond_to session, :ip_addr
  end
  test "should respond to expires_at" do
    session=Session.new
    assert_respond_to session, :expires_at
  end
  test "should respond to remember_token" do
    session=Session.new
    assert_respond_to session, :remember_token
  end

  test "should create new remember token" do
    assert_respond_to Session, :new_remember_token
  end

  test "should create session when valid" do
    session=Session.new(valid)
    assert session.valid?
  end

  test "should not create session without user" do
    session=Session.new(valid.except(:user))
    assert_not session.valid?
  end

  test "should not create session without ip_addr" do
    session=Session.new(valid.except(:ip_addr))
    assert_not session.valid?
  end

  test "should not create session without remember_token" do
    session=Session.new(valid.except(:remember_token))
    assert_not session.valid?
  end



  private
    def valid
      @user||={user: users(:one), ip_addr: "127.0.0.1", remember_token: "token here", expires_at: DateTime.now+20.years}
    end
end
