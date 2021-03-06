defmodule BankApiWeb.UserController do
  @moduledoc """
    Contain all actions the routes User
  """

  use BankApiWeb, :controller
  alias BankApi.Accounts
  alias BankApi.Accounts.Auth.Guardian


  action_fallback BankApiWeb.FallbackController

  @doc """
    Sign up a user
  """
  def signup(conn, %{"user" => user}) do
    with {:ok, user, account} <- Accounts.create_user(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, id: user.id))
      |> render("account.json", %{user: user, account: account})
    end
  end

  @doc """
  Authenticate the user
  """
  def signin(conn, %{"email" => email, "password" => password}) do
    with {:ok, user, token} <- Guardian.authenticate(email, password) do
      conn
      |> put_status(:created)
      |> render("user_auth.json", %{user: user, token: token})
    end
  end

  @doc """
    Render all users
  """
  def index(conn, _) do
    users = Accounts.get_users();
    conn
    |> render("index.json", users: users)
  end

  @doc """
    Render one user by id
  """
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    conn
      |> render("show.json", user: user)
  end
end
