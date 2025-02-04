defmodule Simulation do
    @moduledoc """
    A simulation module demonstrating the Solana transaction process using the Transaction module.
    """
    def run_demo(sender, recipient, amount) do
      IO.puts("\n🚀 Solana Transaction Demo 🚀")
      IO.puts("=========================\n")

      # IO.puts("📡 Checking RPC Connection...")
      url = Transaction.read_rpc_client()
      IO.puts("✅ Connected to: #{url}\n")
      process_transaction(sender, recipient, amount)
    end

    defp process_transaction(sender, recipient, amount) do
      # Step 2: Read Keypair
      IO.puts("🔑 Loading Wallet...")
      case File.read("wallet.json") do
        {:ok, keypair_json} ->
          keypair_base58 =
            keypair_json
            |> Jason.decode!()
            |> :binary.list_to_bin()
            |> Base58.encode()

          IO.puts("""
          ✅ Wallet Loaded
          📤 Sender: #{String.slice(sender, 0..8)}...
          📥 Recipient: #{String.slice(recipient, 0..8)}...
          💰 Amount: #{amount} lamports (#{amount / 1_000_000_000} SOL)
          """)

          # Step 3: Make Transaction
          IO.puts("🚀 Sending Transaction...")
          Transaction.make_transaction(sender, recipient, amount, keypair_base58)

        {:error, _} ->
          IO.puts("❌ Failed to load wallet.json")
      end
    end

      @doc """
    Prints a helpful usage guide
    """
    def print_usage do
      IO.puts("""
      🌟 Solana Transaction Demo Usage Guide 🌟
      ======================================

      This demo shows how to:
      1. Create a Solana transaction
      2. Sign it with your keypair
      3. Send it to the network

      Prerequisites:
      -------------
      1. A Solana keypair file (generate with `solana-keygen new`)
      2. Some SOL in your wallet (use `solana airdrop` on devnet)
      3. The recipient's public key

      To run the demo:
      --------------
      iex> Simulation.run_demo()

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
      Currently using: Devnet
      RPC URL: https://api.devnet.solana.com
      """)
    end

end
