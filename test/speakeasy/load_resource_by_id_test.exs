defmodule Speakeasy.LoadResourceByIDTest do
  use ExUnit.Case, async: true
  alias Speakeasy.LoadResourceByID

  test "updates the resolution's context with the results of loader.(id)" do
    resolution = %{
      context: %{
        current_user: "chauncy"
      },
      state: :unresolved,
      arguments: %{id: "3", name: "foo"}
    }

    loader = fn id -> {:ok, "Received ID: #{id}"} end

    %{context: %{speakeasy: context}} = LoadResourceByID.call(resolution, loader)
    assert context == %Speakeasy.Context{resource: "Received ID: 3"}
  end

  test "updates the resolution's context with the results of loader.(id) when the user is under a different key" do
    resolution = %{
      context: %{
        user: "chauncy"
      },
      state: :unresolved,
      arguments: %{id: "3", name: "foo"}
    }

    loader = fn id -> {:ok, "Received ID: #{id}"} end

    %{context: %{speakeasy: context}} = LoadResourceByID.call(resolution, loader: loader, user_key: :user)
    assert context == %Speakeasy.Context{resource: "Received ID: 3"}
  end
end
