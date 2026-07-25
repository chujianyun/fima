---
name: fima
description: Manage Fima expense reimbursements. Use when someone needs to check the current Fima account, sign in or out, or create, query, invoice, approve, reject, or simulate payment for reimbursement claims.
---

# Fima 财务报销

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

Use `login` to open the browser and complete sign-in in its dedicated login dialog. The CLI polls for the completed browser session and saves its cookie locally; it never accepts a password as a command-line argument. When the browser confirms that CLI login is complete, it is safe to close that browser page:

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

## JSON 参数约定

字段超过两个的命令必须通过 `--json` 传入单个 JSON 对象；先看命令帮助确认必填字段。`create` 的必填字段为 `title`、`amount`、`date`；流程命令的必填字段为 `id`，而 `reject` 还必须包含 `comment`：

```sh
"$CLI_BIN" create --json '{"title":"客户拜访","amount":280,"date":"2026-07-12"}'
"$CLI_BIN" manager-approve --json '{"id":1,"operator":"李主管","comment":"同意"}'
"$CLI_BIN" reject --json '{"id":1,"operator":"李主管","comment":"请补充发票"}'
```

`list`、`show` 和 `upload` 可继续使用普通参数。
