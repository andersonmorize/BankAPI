defmodule BankApi.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :account_from, :string
    field :account_to, :string
    field :date, :date
    field :type, :string
    field :value, :decimal

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:value, :account_from, :account_to, :type, :date])
    |> validate_required([:value, :account_from, :account_to, :type, :date])
  end
end
