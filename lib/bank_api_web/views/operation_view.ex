defmodule BankApiWeb.OperationView do
  use BankApiWeb, :view

  def render("success.json", %{message: message}) do
    %{
      message: message
    }
  end

  def render("error_message.json", %{message: message}) do
    %{
      error: %{message: message}
    }
  end
end
