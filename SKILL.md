---
name: fima
description: Install and use the Fima finance-reimbursement CLI. Use when Codex needs to check the current Fima account, sign in or out, or work with Fima reimbursement, invoice, approval, rejection, or payment operations.
---

# Fima 财务 CLI

Use this Skill to operate the local Fima CLI. The CLI talks to a running Fima Web service; default URL is `http://127.0.0.1:8000`.

## Install and verify

Run the bundled installer before the first command. It clones `https://github.com/chujianyun/fima-cli.git` (branch `main`) into the user's local data directory and runs the upstream installer. Capture its output as the executable path:

```sh
CLI_BIN="$("<skill-directory>/scripts/ensure_fima_cli.sh")"
"$CLI_BIN" -v
"$CLI_BIN" -h
```

The installer is idempotent. Set `FIMA_CLI_INSTALL_ROOT` to choose a different local checkout. Set `FIMA_CLI_UPDATE=1` only when an explicit refresh of the checked-out CLI is wanted.

If the Fima service is elsewhere, set `FIMA_URL` for the command or add `--url <service-url>` before the subcommand. Do not expose passwords, session files, or cookies in output.

## Account commands

Always check the current account before performing account-dependent work:

```sh
"$CLI_BIN" whoami
```

Use `login` to open the browser and complete sign-in there. The CLI polls for the completed browser session and saves its cookie locally; it never accepts a password as a command-line argument:

```sh
"$CLI_BIN" login
```

The default wait is five minutes; use `--timeout <seconds>` only when a longer or shorter window is needed.

Log out only when requested; it clears the local Fima session cookie:

```sh
"$CLI_BIN" logout
```

## Other Fima operations

Do not guess command flags or workflows. First inspect the top-level help, then the specific command's help, and use the documented arguments:

```sh
"$CLI_BIN" -h
"$CLI_BIN" <command> -h
```

This includes reimbursement creation and submission, invoice upload, list/detail queries, manager and finance approvals, payment, and rejection. Confirm any action that submits, approves, rejects, pays, or otherwise changes a reimbursement unless the user has already asked for that specific action.
