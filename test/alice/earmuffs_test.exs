defmodule Alice.EarmuffsTest do
  use Alice.HandlersCase, handlers: Alice.Earmuffs

  alias Alice.Conn
  alias Alice.Earmuffs

  @user_id "some user id"
  @channel_id "some channel id"
  @namespace {Earmuffs, :earmuffs}

  def conn_with_state(state \\ %{}) do
    Conn.make(%{user: @user_id, channel: @channel_id}, %{}, state)
  end

  test "it responds to earmuffs command and sets the block" do
    conn =
      Conn.make(
        %{text: "<@alice> earmuffs", channel: @channel_id, user: @user_id},
        %{users: %{@user_id => %{id: @user_id, name: "fake_user"}}, me: %{id: :alice}}
      )

    conn = send_message(conn)

    assert first_reply() == "<@#{@user_id}> :mute:"
    assert Earmuffs.blocked?(conn)
  end

  test "block adds the user and channel to the blocklist" do
    conn = conn_with_state(%{})
    %Conn{state: state} = Earmuffs.block(conn)

    assert %{@namespace => %{@user_id => [@channel_id]}} = state
  end

  test "block still blocks a user and channel when user already has a channel" do
    conn = conn_with_state(%{@namespace => %{@user_id => ["another"]}})
    %Conn{state: state} = Earmuffs.block(conn)

    assert %{@namespace => %{@user_id => [@channel_id, "another"]}} = state
  end

  test "block still blocks a user and channel when another user has a channel" do
    conn = conn_with_state(%{@namespace => %{"user" => ["channel"]}})
    %Conn{state: state} = Earmuffs.block(conn)

    assert %{@namespace => %{"user" => ["channel"], @user_id => [@channel_id]}} = state
  end

  test "blocked? is false when nothing is blocked" do
    conn = conn_with_state(%{})

    refute Earmuffs.blocked?(conn)
  end

  test "blocked? is true when the conn is blocked for this channel and user" do
    conn = conn_with_state(%{@namespace => %{@user_id => ["another channel", @channel_id]}})

    assert Earmuffs.blocked?(conn)
  end

  test "blocked? is false when channel is blocked but not user" do
    conn = conn_with_state(%{@namespace => %{"another user" => [@channel_id]}})

    refute Earmuffs.blocked?(conn)
  end

  test "blocked? is false when user is blocked but not channel" do
    conn = conn_with_state(%{@namespace => %{@user_id => ["another channel"]}})

    refute Earmuffs.blocked?(conn)
  end

  test "unblock adds an empty channel list for the user when state is empty" do
    conn = conn_with_state(%{})
    conn = Earmuffs.unblock(conn)

    assert conn.state == %{@namespace => %{@user_id => []}}
  end

  test "unblock removes a block for a user and channel" do
    conn = conn_with_state(%{@namespace => %{@user_id => [@channel_id, "other"]}})
    conn = Earmuffs.unblock(conn)

    assert conn.state == %{@namespace => %{@user_id => ["other"]}}
  end
end
