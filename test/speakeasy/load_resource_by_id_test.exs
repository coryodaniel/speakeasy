defmodule Speakeasy.LoadResourceByIDTest do
  use ExUnit.Case, async: true
  alias Speakeasy.LoadResourceByID

  def mock_resolution() do
    %Absinthe.Resolution{
      state: :unresolved,
      arguments: %{id: "3", name: "foo"},
      context: %{
        current_user: "chauncy",
        speakeasy: %Speakeasy.Context{
          user: "chauncy"
        }
      }
    }
  end

  test "updates the resolution's context with the results of loader.(id)" do
    resolution = mock_resolution()
    loader = fn id -> {:ok, "Received ID: #{id}"} end

    %{context: %{speakeasy: context}} = LoadResourceByID.call(resolution, loader)
    assert context == %Speakeasy.Context{resource: "Received ID: 3", user: "chauncy"}
  end

  test "updates the resolution's context with the results of loader.(id) when the user is under a different key" do
    resolution = mock_resolution()
    loader = fn id -> {:ok, "Received ID: #{id}"} end

    %{context: %{speakeasy: context}} =
      LoadResourceByID.call(resolution, loader: loader, user_key: :user)

    assert context == %Speakeasy.Context{resource: "Received ID: 3", user: "chauncy"}
  end
end
