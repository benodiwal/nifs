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
# Check connection and configuration
iex> Demo.check_connection()
iex> Demo.show_config()

# Get help
iex> Demo.help()

# Regular Transaction Demo
iex> Demo.run_transaction(sender, recipient, amount)

# NFT Minting Demo
iex> Demo.run_mint_nft(creator_key, "My NFT", "MNFT", "https://example.com/metadata.json")
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
