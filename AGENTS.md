# AGENTS.md

## Cursor Cloud specific instructions

### Overview

TradingAgents is a multi-agent LLM-powered financial trading framework (Python package + CLI). It uses LangGraph to orchestrate specialized agents (analysts, researchers, traders, risk managers, portfolio managers) for collaborative market analysis. See `README.md` for full architecture details.

### Prerequisites

- **Python 3.10+** (system Python 3.12 is fine)
- **At least one LLM API key** for full end-to-end analysis: `OPENAI_API_KEY`, `GOOGLE_API_KEY`, `ANTHROPIC_API_KEY`, `XAI_API_KEY`, or `OPENROUTER_API_KEY`
- No Docker, database, or external infrastructure required

### Key Commands

| Task | Command |
|------|---------|
| Install deps | `pip install .` |
| Run tests | `python3 -m pytest tests/ -v` |
| Lint | `ruff check .` |
| Launch CLI | `tradingagents` or `python3 -m cli.main` |
| Run programmatically | `python3 main.py` |

### Caveats and Gotchas

- The CLI (`tradingagents`) is an interactive terminal UI using `questionary`/`typer` prompts — it cannot be run non-interactively without scripting stdin.
- `TradingAgentsGraph.__init__()` immediately creates LLM client connections, so it will fail without a valid API key even if you only want to test non-LLM components. To test data pipelines independently, use `tradingagents.dataflows.interface.route_to_vendor()` directly.
- The default data vendor is `yfinance` which requires no API key. Market data fetching and technical indicators work without any credentials.
- `python-dotenv` is used in `main.py` and `cli/main.py` to load `.env` files but is not listed in `pyproject.toml` dependencies — it is installed as a transitive dependency.
- The `ruff check .` linter reports ~138 pre-existing style issues (mostly unused imports from star-imports). These are not regressions.
- The `$HOME/.local/bin` directory must be on PATH for the `tradingagents` CLI entry point and `pytest`/`ruff` to be found.
- No lint/format tool configuration exists in `pyproject.toml`; `ruff check .` uses defaults.
