# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BankApi.Repo.insert!(%BankApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
BankApi.Accounts.create_user %User{}, %{email: "testmorize@gmail.com", first_name: "Teste", last_name: "Morize", password: "123123", password_confirmation: "123123"}
Transaction.changeset %Transaction{}, %{date: Date.utc_today, account_from: "123123", account_to: "123123123" type: "transfer" value: 100}
