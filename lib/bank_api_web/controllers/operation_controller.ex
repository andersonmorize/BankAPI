defmodule BankApiWeb.OperationController do
  @moduledoc """
  Contain all actions the routes Operations

  ## Functions
  -`transfer/2`
  -`withdraw/2`
  """

  use BankApiWeb, :controller
  alias BankApi.Operations
  alias BankApi.Accounts

  action_fallback BankApiWeb.FallbackController

  @doc """
  Make a transfer from authenticated user to another user with value the account
  """
  def transfer(conn, %{"to_account_id" => t_id, "value" => value}) do
    user = Guardian.Plug.current_resource(conn)
    to = Accounts.get!(t_id)
    value = Decimal.new(value)
    with {:ok, message} <- Operations.transfer(user.accounts, to, value) do
      conn
      |> render("success.json", message: message)
    end
  end

  @doc """
  Withdraw a value the account from authenticated user
  """
  def withdraw(conn, %{"value" => value}) do
    user = Guardian.Plug.current_resource(conn)
    value = Decimal.new(value)
    with {:ok, message} <- Operations.withdraw(user.accounts, value) do
      conn
      |> render("success.json", message: message)
    end
  end
end
