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

    %{context: context} = LoadResourceByID.call(resolution, loader)
    assert context == %{speakeasy: %{resource: "Received ID: 3"}, current_user: "chauncy"}
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

    %{context: context} = LoadResourceByID.call(resolution, loader)
    assert context == %{speakeasy: %{resource: "Received ID: 3"}, user: "chauncy"}
  end
end
