defmodule Simulation do
  @moduledoc """
  A simulation module demonstrating both Solana transactions and NFT minting using the Transaction module.
  """

  def run_transaction_demo(sender, recipient, amount) do
    IO.puts("\n🚀 Solana Transaction Demo 🚀")
    IO.puts("=========================\n")

    case Transaction.get_rpc_url() do
      {:ok, url} ->
        IO.puts("✅ Connected to: #{url}\n")
        process_transaction(sender, recipient, amount)

      {:error, reason} ->
        IO.puts("❌ Failed to connect to RPC: #{reason}")
    end
  end

  def run_nft_demo(creator_key, name, symbol, uri) do
    IO.puts("\n🎨 Solana NFT Minting Demo 🎨")
    IO.puts("=========================\n")

    case Transaction.get_rpc_url() do
      {:ok, url} ->
        IO.puts("✅ Connected to: #{url}\n")
        process_nft_minting(creator_key, name, symbol, uri)

      {:error, reason} ->
        IO.puts("❌ Failed to connect to RPC: #{reason}")
    end
  end

  defp process_transaction(sender, recipient, amount) do
    IO.puts("🔑 Loading Wallet...")

    case File.read("wallet.json") do
      {:ok, keypair_json} ->
        private_key_hex = extract_private_key(keypair_json)

        IO.puts("""
        ✅ Wallet Loaded
        📤 Sender: #{String.slice(sender, 0..8)}...
        📥 Recipient: #{String.slice(recipient, 0..8)}...
        💰 Amount: #{amount} lamports (#{amount / 1_000_000_000} SOL)
        """)

        case Transaction.make_transaction(sender, recipient, amount, private_key_hex) do
          {:ok, signature} ->
            IO.puts("✅ Transaction Successful!")
            IO.puts("📝 Signature: #{signature}")
            {:ok, signature}

          {:error, reason} ->
            IO.puts("❌ Transaction Failed: #{reason}")
            {:error, reason}
        end

      {:error, _} ->
        IO.puts("❌ Failed to load wallet.json")
        {:error, "Failed to load wallet"}
    end
  end

  defp process_nft_minting(creator_key, name, symbol, uri) do
    IO.puts("""
    🎨 Preparing NFT Mint
    Name: #{name}
    Symbol: #{symbol}
    URI: #{uri}
    """)

    case Transaction.mint_nft(creator_key, name, symbol, uri) do
      {:ok, signature} ->
        IO.puts("✅ NFT Minting Successful!")
        IO.puts("📝 Signature: #{signature}")
        {:ok, signature}

      {:error, reason} ->
        IO.puts("❌ NFT Minting Failed: #{reason}")
        {:error, reason}
    end
  end

  defp extract_private_key(keypair_json) do
    case Jason.decode(keypair_json) do
      {:ok, decoded} when is_list(decoded) ->
        decoded
        |> :binary.list_to_bin()
        |> Base.encode16(case: :lower)

      _ ->
        raise "Invalid keypair format"
    end
  end

  @doc """
  Prints a helpful usage guide
  """
  def print_usage do
    IO.puts("""
    🌟 Solana Transaction and NFT Demo Usage Guide 🌟
    =============================================

    This demo shows how to:
    1. Create and send Solana transactions
    2. Mint NFTs on Solana
    3. Sign transactions with your keypair

    Prerequisites:
    -------------
    1. A Solana keypair file (generate with `solana-keygen new`)
    2. Some SOL in your wallet (use `solana airdrop` on devnet)
    3. For transfers: recipient's public key
    4. For NFTs: metadata URI

    To run the demos:
    --------------
    # For SOL transfer:
    iex> Simulation.run_transaction_demo(sender, recipient, amount)

    # For NFT minting:
    iex> Simulation.run_nft_demo(creator_key, name, symbol, uri)

    For development setup:
    -------------------
    1. Generate a new keypair:
       $ solana-keygen new --outfile wallet.json

    2. Get some test SOL:
       $ solana airdrop 1 <YOUR-PUBLIC-KEY> --url https://api.devnet.solana.com

    3. Check your balance:
       $ solana balance <YOUR-PUBLIC-KEY> --url https://api.devnet.solana.com

    Network Configuration:
    -------------------
    Uses the RPC URL configured in your application
    """)
  end
end
