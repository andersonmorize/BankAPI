defmodule BankApi.Transactions do
  import Ecto.Query, warn: false
  alias BankApi.Repo
  alias BankApi.Transactions.Transaction

  def all do
    Repo.all(Transaction)
    |> create_payload()
  end

  def year(year) do
    filter_query(Date.from_erl!({year, 01, 01}), Date.from_erl!({year, 12, 31}))
  end

  def month(year, month) do
    start_date = Date.from_erl!({year, month, 01})
    days_in_month = start_date |> Date.days_in_month()
    end_date = Date.from_erl!({year, month, days_in_month})
    filter_query(start_date, end_date)
  end

  def day(date) do
    query = from t in Transaction, where: t.date == ^date
    Repo.all(query)
    |> create_payload()
  end

  def create_payload(transactions) do
    %{transactions: transactions, total: calculate_value(transactions)}
  end

  def calculate_value(transactions) do
    Enum.reduce(transactions, Decimal.new("0"), fn t, acc ->
      Decimal.add(acc, t.value)
    end)
  end

  defp filter_query(start_date, end_date) do
    query = from t in Transaction, where: t.date >= ^start_date and t.date <= ^end_date

    Repo.all(query)
    |> create_payload()
  end
end
