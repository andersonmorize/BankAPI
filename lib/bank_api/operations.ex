defmodule BankApi.Operations do
  alias BankApi.Accounts
  alias BankApi.Accounts.Account
  alias BankApi.Repo
  alias BankApi.Transactions.Transaction
  alias Ecto.Multi

  @withdraw "withdraw"
  @transfer "transfer"

  def transfer(from, t_id, value) do
    validate_negative(from.balance, value, perform_update(from, t_id, value))
  end

  def withdraw(from, value) do
    validate_negative(from.balance, value, withdraw_operation(from, value))
  end

  defp validate_negative(balance, value, operation) do
    case is_negative?(balance, value) do
      true -> {:error, "you can't have negative balance!"}
      false ->
        operation
    end
  end

  defp withdraw_operation(from, value) do
    Multi.new()
    |> Multi.update(:account_from, perform_operation(from, value, :sub))
    |> Multi.insert(:transaction, gen_transaction(value, from.id, nil, @withdraw))
    |> Repo.transaction()
    |> transaction_case("Transfer with success!! from: #{from.id} value: #{value}")
  end

  defp is_negative?(from_balance, value) do
    Decimal.sub(from_balance, value)
    |> Decimal.negative?()
  end

  def perform_update(from, t_id, value) do
    to = Accounts.get!(t_id)

    Multi.new()
    |> Multi.update(:account_from, perform_operation(from, value, :sub))
    |> Multi.update(:account_to, perform_operation(to, value, :sum))
    |> Multi.insert(:transaction, gen_transaction(value, from.id, to.id, @transfer))
    |> Repo.transaction()
    |> transaction_case("Transfer with success!! from: #{from.id} to: #{to.id} value: #{value}")

  end

  defp transaction_case(operation, message) do
    case operation do
      {:ok, _} ->
        {:ok, message}
      {:error, :account_from, changeset, _} -> {:error, changeset}
      {:error, :account_to, changeset, _} -> {:error, changeset}
      {:error, :transaction, changeset, _} -> {:error, changeset}
    end
  end

  def perform_operation(account, value, :sub) do
    account
      |> update_account(%{balance: Decimal.sub(account.balance, value)})
  end

  def perform_operation(account, value, :sum) do
    account
      |> update_account(%{balance: Decimal.add(account.balance, value)})
  end

  def update_account(%Account{} = account, attrs) do
    Account.changeset(account, attrs)
  end

  defp gen_transaction(value, f_id, t_id, type) do
    %Transaction{value: value, account_from: f_id, account_to: t_id, type: type, date: Date.utc_today()}
  end
end
