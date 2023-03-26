defmodule ChoisiWeb.User do
  alias __MODULE__
  defstruct [:id, :name, :color]

  def generate_name do
    "User #{Enum.random(1..1000)}"
  end

  def generate_id do
    Integer.to_string(:rand.uniform(4_294_967_296), 32)
  end

  def generate_color do
    Enum.random(["red", "green", "blue", "yellow", "purple", "orange", "pink", "black"])
  end

  @spec create :: %ChoisiWeb.User{color: String.t(), id: String.t(), name: String.t()}
  def create do
    %User{id: generate_id(), name: generate_name(), color: generate_color()}
  end
end
