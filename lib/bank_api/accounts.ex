defmodule BankApi.Accounts do
  @moduledoc """
  Context for Users and Accounts
  """
  alias BankApi.Repo
  alias BankApi.Accounts.{User, Account}

  @doc """
  Create a new user with your account

  ## Parameters
    - attrs: One map with user attributes
  """
  def create_user(attrs \\ %{}) do
    transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, insert_user(attrs))
      |> Ecto.Multi.insert(:account, fn %{user: user} ->
        user
        |> Ecto.build_assoc(:accounts)
        |> Account.changeset()
      end)
      |> Repo.transaction()

    case transaction do
      {:ok, operations} -> {:ok, operations.user, operations.account}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Convert attributes in a Changeset from User
  """
  def insert_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
  end

  @doc """
  Get a user by id and your respective account
  """
  def get_user!(id), do: Repo.get(User, id) |> Repo.preload(:accounts)

  @doc """
  Get a account by id
  """
  def get!(id), do: Repo.get(Account, id);

  @doc """
  Get all users by id and their respective account
  """
  def get_users(), do: Repo.all(User) |> Repo.preload(:accounts)
end
