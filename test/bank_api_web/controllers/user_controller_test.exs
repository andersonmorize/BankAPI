defmodule BankApiWeb.UserControllerTest do
  use BankApiWeb.ConnCase
  alias BankApi.Accounts
  import BankApi.Accounts.Auth.Guardian

  @create_attrs %{
    email: "some@email.com",
    first_name: "some first_name",
    last_name: "some last_name",
    password: "somepassword",
    password_confirmation: "somepassword"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  def fixture(:user) do
    {:ok, user, _account} = Accounts.create_user(@create_attrs)
    user
  end

  test "authenticate with success", %{conn: conn} do
    user = fixture(:user)
    conn = post(conn, Routes.user_path(conn, :signin), email: user.email, password: "somepassword")
    result = json_response(conn, 201)
    assert "some@email.com" == Map.get(result, "data") |> Map.get("email")
  end

  test "list all users", %{conn: conn} do
    user = fixture(:user)
    {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)
    conn = put_req_header(conn, "authorization", "bearer " <> token)

    conn = get(conn, Routes.user_path(conn, :index))
    assert 1 == Enum.count(json_response(conn, 200)["data"])
  end

end
