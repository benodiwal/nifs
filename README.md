# Solana Transaction NIFs

Making Solana transactions using Elixir through `Rustler Bridge` using NIFs.

## 🚀 Quick Start

### 1. Configuration

Change `configs.yaml` with your preferred Solana network:

```yaml
rpc_url: "https://api.devnet.solana.com"
```

Available networks:
- `https://api.mainnet-beta.solana.com` (Mainnet)
- `https://api.testnet.solana.com` (Testnet)
- `https://api.devnet.solana.com` (Devnet)
- `http://localhost:8899` (Local node)

### 2. Setup Wallet

```bash
# Generate a new keypair
solana-keygen new --outfile wallet.json

# Get test SOL (for devnet)
solana airdrop 1 $(solana-keygen pubkey wallet.json) --url https://api.devnet.solana.com
```

### 3. Run Demo

```bash
# Start Elixir interactive shell
iex -S mix

# In the IEx shell:
iex> Demo.help()    # Show usage guide
iex> Demo.run(sender, recipient, amount)   # Run demo

## Sender, Recipient are PubKeys
```

## 💻 Development Setup

1. Install dependencies:
   ```bash
   mix deps.get
   ```

2. Configure your network in `configs.yaml`

3. Generate a wallet:
   ```bash
   solana-keygen new --outfile wallet.json
   ```

4. Get test SOL (for devnet):
   ```bash
   solana airdrop 1 $(solana-keygen pubkey wallet.json) --url https://api.devnet.solana.com
   ```
