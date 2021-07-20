defmodule BankApiWeb.FallbackController do
  @moduledoc """
  Get a error and render a response
  """
  use BankApiWeb, :controller

  @doc """
  Render an error response in Changeset format
  """
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
      |> put_status(:unprocessable_entity)
      |> put_view(BankApiWeb.ChangesetView)
      |> render("error.json", changeset: changeset)
  end

  @doc """
  Render an error response in any format
  """
  def call(conn, {:error, message}) do
    conn
      |> put_status(:unprocessable_entity)
      |> put_view(BankApiWeb.ErrorView)
      |> render("error_message.json", message: message)
  end
end
