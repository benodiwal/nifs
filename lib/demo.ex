defmodule Demo do
  @moduledoc """
  A convenience module for running demonstrations of Solana transactions and NFT minting.
  """

  @doc """
  Runs a demonstration of a Solana transaction.

  ## Parameters
    * `sender` - The sender's public key in base58 format
    * `recipient` - The recipient's public key in base58 format
    * `amount` - The amount to send in lamports

  ## Example
      iex> Demo.run_transaction("sender_key", "recipient_key", 1_000_000)
  """
  def run_transaction(sender, recipient, amount), do:
    Simulation.run_transaction_demo(sender, recipient, amount)

  @doc """
  Runs a demonstration of NFT minting.

  ## Parameters
    * `creator_key` - The creator's private key in base58 format
    * `name` - The name of the NFT
    * `symbol` - The symbol of the NFT
    * `uri` - The URI pointing to the NFT's metadata

  ## Example
      iex> Demo.run_mint_nft("creator_key", "My NFT", "MNFT", "https://example.com/metadata.json")
  """
  def run_mint_nft(creator_key, name, symbol, uri), do:
    Simulation.run_nft_demo(creator_key, name, symbol, uri)

  @doc """
  Displays help information about using the demo functions.

  ## Example
      iex> Demo.help()
  """
  def help, do: Simulation.print_usage()

  @doc """
  Displays the current configuration including RPC URL and network.

  ## Example
      iex> Demo.show_config()
  """
  def show_config do
    case Transaction.get_rpc_url() do
      {:ok, url} ->
        IO.puts("""
        Current Configuration:
        ---------------------
        RPC URL: #{url}
        Network: #{if String.contains?(url, "devnet"), do: "Devnet", else: "Mainnet"}
        """)
      {:error, reason} ->
        IO.puts("Error fetching configuration: #{reason}")
    end
  end

  @doc """
  Quick health check of the connection to Solana network.

  ## Example
      iex> Demo.check_connection()
  """
  def check_connection do
    case Transaction.get_rpc_url() do
      {:ok, url} ->
        case Transaction.get_recent_blockhash(url) do
          {:ok, _} ->
            IO.puts("✅ Connection successful!")
          {:error, reason} ->
            IO.puts("❌ Connection failed: #{reason}")
        end
      {:error, reason} ->
        IO.puts("❌ Failed to get RPC URL: #{reason}")
    end
  end
end
