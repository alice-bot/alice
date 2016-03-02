defmodule Alice.EarmuffsTest do
  use ExUnit.Case, async: true
  alias Alice.Earmuffs

  @user_id "some user id"
  @channel_id "some channel id"

  def conn_with_state(state \\ %{}) do
    Alice.Conn.make(%{user: @user_id, channel: @channel_id}, %{}, state)
  end

  test "block adds the user and channel to the blocklist" do
    %Alice.Conn{state: state} = %{} |> conn_with_state |> Earmuffs.block
    assert %{{Alice.Earmuffs, :earmuffs} => %{@user_id => [@channel_id]}} = state
  end

  test "block adds the user and channel to the blocklist when user already has a channel" do
    conn = conn_with_state(%{{Alice.Earmuffs, :earmuffs} => %{@user_id => ["another"]}})
    %Alice.Conn{state: state} = Earmuffs.block(conn)
    assert %{{Alice.Earmuffs, :earmuffs} => %{@user_id => [@channel_id, "another"]}} = state
  end

  test "block adds the user and channel to the blocklist when another user already has a channel" do
    conn = conn_with_state(%{{Alice.Earmuffs, :earmuffs} => %{"user" => ["channel"]}})
    %Alice.Conn{state: state} = Earmuffs.block(conn)
    assert %{{Alice.Earmuffs, :earmuffs} => %{"user" => ["channel"], @user_id => [@channel_id]}} = state
  end

  test "blocked? is false when nothing is blocked" do
    %{}
    |> conn_with_state
    |> Earmuffs.blocked?
    |> refute
  end

  test "blocked? is true when the conn is blocked for this channel and user" do
    %{{Alice.Earmuffs, :earmuffs} => %{@user_id => ["another channel", @channel_id]}}
    |> conn_with_state
    |> Earmuffs.blocked?
    |> assert
  end

  test "blocked? is false when the conn is blocked for this channel and a different user" do
    %{{Alice.Earmuffs, :earmuffs} => %{"another user" => [@channel_id]}}
    |> conn_with_state
    |> Earmuffs.blocked?
    |> refute
  end

  test "blocked? is false when the conn is blocked for this user and a different channel" do
    %{{Alice.Earmuffs, :earmuffs} => %{@user_id => ["another channel"]}}
    |> conn_with_state
    |> Earmuffs.blocked?
    |> refute
  end

  test "unblock adds an empty channel list for the user when state is empty" do
    unblocked_conn = %{}
                     |> conn_with_state
                     |> Earmuffs.unblock
    assert unblocked_conn.state == %{{Alice.Earmuffs, :earmuffs} => %{@user_id => []}}
  end

  test "unblock removes a block for a user and channel" do
    unblocked_conn = %{{Alice.Earmuffs, :earmuffs} => %{@user_id => [@channel_id, "other"]}}
                     |> conn_with_state
                     |> Earmuffs.unblock
    assert unblocked_conn.state == %{{Alice.Earmuffs, :earmuffs} => %{@user_id => ["other"]}}
  end
end
