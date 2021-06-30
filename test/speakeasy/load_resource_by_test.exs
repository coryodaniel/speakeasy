defmodule Speakeasy.LoadResourceByTest do
  use ExUnit.Case, async: true
  alias Speakeasy.LoadResourceBy

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
    name_loader = fn name -> {:ok, "Received NAME: #{name}"} end
    id_loader = fn id -> {:ok, "Received ID: #{id}"} end

    %{context: %{speakeasy: context}} = LoadResourceBy.call(resolution, {:name, name_loader})
    assert context == %Speakeasy.Context{resource: "Received NAME: foo", user: "chauncy"}

    %{context: %{speakeasy: context}} = LoadResourceBy.call(resolution, {:id, id_loader})
    assert context == %Speakeasy.Context{resource: "Received ID: 3", user: "chauncy"}
  end

  test "updates the resolution's context with the results of loader.(id) when the user is under a different key" do
    resolution = mock_resolution()
    id_loader = fn id -> {:ok, "Received ID: #{id}"} end
    name_loader = fn name -> {:ok, "Received NAME: #{name}"} end

    %{context: %{speakeasy: context}} =
      LoadResourceBy.call(resolution, key: :id, loader: id_loader, user_key: :user)

    assert context == %Speakeasy.Context{resource: "Received ID: 3", user: "chauncy"}

    %{context: %{speakeasy: context}} =
      LoadResourceBy.call(resolution, key: :name, loader: name_loader, user_key: :user)

    assert context == %Speakeasy.Context{resource: "Received NAME: foo", user: "chauncy"}
  end

  test "doesn't do anything if the resolution is already resolved" do
    resolution = %{mock_resolution() | state: :resolved}
    loader = fn id -> {:ok, id} end

    assert resolution ==
             LoadResourceBy.call(resolution, key: :id, loader: loader)
  end
end
