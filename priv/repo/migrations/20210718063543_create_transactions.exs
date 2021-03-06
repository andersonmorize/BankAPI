defmodule BankApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :value, :decimal, precision: 10, scale: 2 
      add :account_from, :string
      add :account_to, :string
      add :type, :string
      add :date, :date

      timestamps()
    end

  end
end
