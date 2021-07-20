defmodule BankApi.Transactions do
  import Ecto.Query, warn: false
  alias BankApi.Repo
  alias BankApi.Transactions.Transaction

  @doc """
  Return all Transactions
  """
  def all do
    Repo.all(Transaction)
    |> create_payload()
  end

  @doc """
  Return Transactions by year

  ## Parameters

    - year: An Integer representing the year
  """
  def year(year) do
    filter_query(Date.from_erl!({year, 01, 01}), Date.from_erl!({year, 12, 31}))
  end

  @doc """
  Return Transactions by month and year

  ## Parameters

    - month: An Integer representing the month
    - year: An Integer representing the year
  """
  def month(year, month) do
    start_date = Date.from_erl!({year, month, 01})
    days_in_month = start_date |> Date.days_in_month()
    end_date = Date.from_erl!({year, month, days_in_month})
    filter_query(start_date, end_date)
  end

  @doc """
  Return Transactions by day, month and year

  Parameters

    - day: An format Date iso8601 with day, month and year
  """
  def day(date) do
    query = from t in Transaction, where: t.date == ^date
    Repo.all(query)
    |> create_payload()
  end

  # Create a map with transactions and total amount the transactions
  defp create_payload(transactions) do
    %{transactions: transactions, total: calculate_value(transactions)}
  end

  # Calculate total amount in transactions
  defp calculate_value(transactions) do
    Enum.reduce(transactions, Decimal.new("0"), fn t, acc ->
      Decimal.add(acc, t.value)
    end)
  end

  # Get all Transactions in a time frame
  defp filter_query(start_date, end_date) do
    query = from t in Transaction, where: t.date >= ^start_date and t.date <= ^end_date

    Repo.all(query)
    |> create_payload()
  end
end
