defmodule BankApi.Operations do
  @moduledoc """
  Set of functions for account operations
  """
  alias BankApi.Accounts.Account
  alias BankApi.Repo
  alias BankApi.Transactions.Transaction
  alias Ecto.Multi

  @withdraw "withdraw"
  @transfer "transfer"

  @doc """
  Make a transfer from authenticated user to another user with value the account

  ##Parameters

    - from: A %Account{} representing the account of the user making the transfer
    - to: A string representing the id of the user who will receive the transfer
    - value: An integer represents the transfer amount
  """
  def transfer(from, to, value) do
    case is_negative?(from.balance, value) do
      true -> {:error, "you can't have negative balance!"}
      false -> transfer_operation(from, to, value)
    end
  end

  @doc """
  Withdraw a value the account from authenticated user

  ##Parameters

  - from: A %Account{} representing the account of the user making the withdrawal
  - value: An integer represents the withdrawal amount
  """
  def withdraw(from, value) do
    case is_negative?(from.balance, value) do
      true -> {:error, "you can't have negative balance!"}
      false -> withdraw_operation(from, value)
    end
  end

  # Update the account balance and create a withdrawal transaction
  defp withdraw_operation(from, value) do
    Multi.new()
    |> Multi.update(:account_from, perform_operation(from, value, :sub))
    |> Multi.insert(:transaction, gen_transaction(value, from.id, nil, @withdraw))
    |> Repo.transaction()
    |> transaction_case("Withdrawal with success!! from: #{from.id} value: #{value}")
  end

  # Update the account balances and create a transfer transaction
  defp transfer_operation(from, to, value) do
    Multi.new()
    |> Multi.update(:account_from, perform_operation(from, value, :sub))
    |> Multi.update(:account_to, perform_operation(to, value, :sum))
    |> Multi.insert(:transaction, gen_transaction(value, from.id, to.id, @transfer))
    |> Repo.transaction()
    |> transaction_case("Transfer with success!! from: #{from.id} to: #{to.id} value: #{value}")
  end

  # Check if the value is negative after the operation
  defp is_negative?(from_balance, value) do
    Decimal.sub(from_balance, value)
    |> Decimal.negative?()
  end

  # validate the message
  defp transaction_case(operation, message) do
    case operation do
      {:ok, _} ->
        {:ok, message}
      {:error, :account_from, changeset, _} -> {:error, changeset}
      {:error, :account_to, changeset, _} -> {:error, changeset}
      {:error, :transaction, changeset, _} -> {:error, changeset}
    end
  end

  # subtract the amount from the account balance
  defp perform_operation(account, value, :sub) do
    account
      |> update_account(%{balance: Decimal.sub(account.balance, value)})
  end

  # sums the amount with account balance
  defp perform_operation(account, value, :sum) do
    account
      |> update_account(%{balance: Decimal.add(account.balance, value)})
  end

  # Update Account Changeset
  defp update_account(%Account{} = account, attrs) do
    Account.changeset(account, attrs)
  end

  # Creates a transaction structure
  defp gen_transaction(value, f_id, t_id, type) do
    %Transaction{value: value, account_from: f_id, account_to: t_id, type: type, date: Date.utc_today()}
  end
end
