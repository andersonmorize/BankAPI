defmodule BankApiWeb.UserView do
  use BankApiWeb, :view

  def render("account.json", %{user: user, account: account}) do
    %{
      user: %{
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role,
        id: user.id,
        accounts: %{
          id: account.id,
          balance: account.balance,
        }
      }
    }
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json")}
  end

  def render("user_auth.json", %{user: user, token: token}) do
    user = Map.put(render_one(user, __MODULE__, "user.json"), :token, token)
    %{data: user}
  end

  def render("index.json", %{users: users}) do
    %{data: render_many(users, __MODULE__, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role,
      account: %{
        id: user.accounts.id,
        balance: user.accounts.balance
      }
    }
  end
end
