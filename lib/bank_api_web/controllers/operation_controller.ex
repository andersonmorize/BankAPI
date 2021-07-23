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
  alias BankApi.Accounts.Account

  action_fallback BankApiWeb.FallbackController

  @doc """
  Make a transfer from authenticated user to another user with value the account
  """
  def transfer(conn, %{"to_account_id" => t_id, "value" => value}) do
    user = Guardian.Plug.current_resource(conn)
    value = format_value(value)

    with to =  %Account{} <- Accounts.get!(t_id),
      true <- !String.match?(user.accounts.id, ~r/#{to.id}/),
      {:ok, message} <- Operations.transfer(user.accounts, to, value) do
        conn
        |> render("success.json", message: message)
    else
      nil ->
        conn
        |> render("error_message.json", %{message: "user not found"})
      false ->
        conn
        |> render("error_message.json", %{message: "you cannot transfer from you to you"})
    end
  end

  @doc """
  Withdraw a value the account from authenticated user
  """
  def withdraw(conn, %{"value" => value}) do
    user = Guardian.Plug.current_resource(conn)
    value = format_value(value)
    with {:ok, message} <- Operations.withdraw(user.accounts, value) do
      conn
      |> render("success.json", message: message)
    end
  end

  # convert string to integer and transform to positive number if negative
  defp format_value(value) do
    value = Decimal.new(value)
    cond do
      true == Decimal.negative?(value) -> Decimal.negate(value)
      true -> value
    end
  end
end
