defmodule Alice.EarmuffsTest do
  use ExUnit.Case, async: true
  alias Alice.Conn
  alias Alice.Earmuffs

  @user_id "some user id"
  @channel_id "some channel id"

  def conn_with_state(state \\ %{}) do
    Conn.make(%{user: @user_id, channel: @channel_id}, %{}, state)
  end

  test "block adds the user and channel to the blocklist" do
    %Conn{state: state} = %{} |> conn_with_state |> Earmuffs.block()
    assert %{{Earmuffs, :earmuffs} => %{@user_id => [@channel_id]}} = state
  end

  test "block block user and channel when user already has a channel" do
    conn =
      %{{Earmuffs, :earmuffs} => %{@user_id => ["another"]}}
      |> conn_with_state

    %Conn{state: state} = Earmuffs.block(conn)

    %{{Earmuffs, :earmuffs} => %{@user_id => [@channel_id, "another"]}} =
      state
      |> assert
  end

  test "block block user and channel when another user has a channel" do
    conn =
      %{{Earmuffs, :earmuffs} => %{"user" => ["channel"]}}
      |> conn_with_state

    %Conn{state: state} = Earmuffs.block(conn)

    %{{Earmuffs, :earmuffs} => %{"user" => ["channel"], @user_id => [@channel_id]}} =
      state
      |> assert
  end

  test "blocked? is false when nothing is blocked" do
    %{}
    |> conn_with_state
    |> Earmuffs.blocked?()
    |> refute
  end

  test "blocked? is true when the conn is blocked for this channel and user" do
    %{{Earmuffs, :earmuffs} => %{@user_id => ["another channel", @channel_id]}}
    |> conn_with_state
    |> Earmuffs.blocked?()
    |> assert
  end

  test "blocked? is false when channel is blocked but not user" do
    %{{Earmuffs, :earmuffs} => %{"another user" => [@channel_id]}}
    |> conn_with_state
    |> Earmuffs.blocked?()
    |> refute
  end

  test "blocked? is false when user is blocked but not channel" do
    %{{Earmuffs, :earmuffs} => %{@user_id => ["another channel"]}}
    |> conn_with_state
    |> Earmuffs.blocked?()
    |> refute
  end

  test "unblock adds an empty channel list for the user when state is empty" do
    unblocked_conn =
      %{}
      |> conn_with_state
      |> Earmuffs.unblock()

    assert unblocked_conn.state == %{{Earmuffs, :earmuffs} => %{@user_id => []}}
  end

  test "unblock removes a block for a user and channel" do
    conn =
      %{{Earmuffs, :earmuffs} => %{@user_id => [@channel_id, "other"]}}
      |> conn_with_state
      |> Earmuffs.unblock()

    assert conn.state == %{{Earmuffs, :earmuffs} => %{@user_id => ["other"]}}
  end
end
