require 'test_helper'

class PubSubsControllerTest < ActionController::TestCase
  setup do
    @pub_sub = pub_subs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pub_subs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pub_sub" do
    assert_difference('PubSub.count') do
      post :create, pub_sub: { blog_url: @pub_sub.blog_url }
    end

    assert_redirected_to pub_sub_path(assigns(:pub_sub))
  end

  test "should show pub_sub" do
    get :show, id: @pub_sub
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pub_sub
    assert_response :success
  end

  test "should update pub_sub" do
    put :update, id: @pub_sub, pub_sub: { blog_url: @pub_sub.blog_url }
    assert_redirected_to pub_sub_path(assigns(:pub_sub))
  end

  test "should destroy pub_sub" do
    assert_difference('PubSub.count', -1) do
      delete :destroy, id: @pub_sub
    end

    assert_redirected_to pub_subs_path
  end
end
