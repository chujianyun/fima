# Fima 财务报销 Skill

这个 Skill 通过本地命令行操作 Fima 财务报销系统：登录、查询报销单、创建报销单、上传发票，以及主管审批、财务审批、驳回和模拟付款。

这个仓库是 **Skill 源码**；实际执行的 CLI 位于关联仓库 [`fima-cli`](../fima-cli)，服务端页面位于 [`fima-web`](../fima-web)。

## 前置条件

1. 启动 Fima Web 服务，并确定可访问的服务器 URL 或 IP:端口。
2. 本机需要安装 `git`，首次使用时 Skill 会自动拉取并安装 `fima-cli`。

CLI 1.4.0 起不再默认连接本机服务。首次使用或更换服务器时保存地址：

```sh
fima config set-url 127.0.0.1:8000
fima config show
```

地址保存到 `~/.fima/config.json`（可用 `FIMA_CONFIG_FILE` 覆盖），重开终端仍有效；未配置时，业务命令会提示设置并退出。支持完整 HTTP/HTTPS URL 或 IP:端口，未写协议时默认 HTTP。更换地址仍使用 `config set-url`。

临时使用其他服务器时，可在命令前设置 `FIMA_URL`，或将 `--url <服务地址>` 放在子命令前：

```sh
FIMA_URL=http://127.0.0.1:8000 fima whoami
fima --url http://127.0.0.1:8000 whoami
```

优先级为 `--url` > `FIMA_URL` > 已保存配置；临时覆盖不会改写配置文件。登录会话与服务器地址绑定，更换服务器或升级旧会话后需要重新登录。旧版 CLI 可继续使用 `--url`，持久化配置命令需要升级到 1.4.0 及以上。

## 安装与验证

Skill 通过随附脚本安装 CLI。脚本可重复执行；它会输出实际 CLI 路径：

```sh
CLI_BIN="$("<skill-directory>/scripts/ensure_fima_cli.sh")"
"$CLI_BIN" -v
"$CLI_BIN" -h
```

默认会将 CLI 安装到 `~/.local/bin/fima`，源码检出到 `~/.local/share/fima-cli`。如需更换检出目录，设置 `FIMA_CLI_INSTALL_ROOT`；只有需要刷新已检出 CLI 时才设置 `FIMA_CLI_UPDATE=1`。

## 登录与账户

先确认当前账户：

```sh
fima whoami
```

未登录时执行：

```sh
fima login
```

该命令会打开浏览器中的专用登录页。账号和密码只在网页输入，CLI 不接收密码参数；网页显示“CLI 登录已完成”后即可关闭。登录会话保存在本地 Cookie 文件中（默认 `~/.fima/session.json`），不要把它提交、打印或分享。

默认登录等待时间为 5 分钟；可按需调整：

```sh
fima login --timeout 600
```

仅在需要时退出，退出会清除本地会话：

```sh
fima logout
```

## 常用操作

```sh
# 查询
fima list
fima list --status submitted
fima show 1

# 创建草稿；title、amount、date 为必填字段
fima create --json '{"title":"客户拜访","amount":280,"date":"2026-07-12"}'

# 创建、上传发票并提交审核
fima create --json '{"title":"上海客户拜访","category":"差旅费","amount":1280,"date":"2026-07-12","invoice":"./invoice.pdf","submit":true}'

# 为已有报销单上传或替换发票
fima upload 1 ./invoice.pdf

# 流转
fima submit --json '{"id":1}'
fima manager-approve --json '{"id":1,"operator":"李主管","comment":"同意"}'
fima finance-approve --json '{"id":1,"operator":"陈会计","comment":"票据无误"}'
fima pay --json '{"id":1,"operator":"陈出纳","comment":"已模拟打款"}'
fima reject --json '{"id":1,"operator":"李主管","comment":"请补充发票"}'
```

可筛选的状态为：`draft`、`submitted`、`manager_approved`、`finance_approved`、`paid`、`rejected`。

## 参数约定

字段超过两个的命令统一用 `--json` 传入一个 JSON 对象。执行前先查看对应帮助，确认当前版本所需字段：

```sh
fima -h
fima create -h
fima manager-approve -h
```

`create` 必填 `title`、`amount`、`date`；流程命令必填 `id`，其中 `reject` 还必须传 `comment`。`list`、`show`、`upload` 使用普通参数。

## 操作边界

查询、查看详情和检查账户可以直接执行。创建、提交、审批、驳回、付款都会改变报销流程状态，执行前应获得明确授权，并在操作前确认当前账号和报销单详情。

## 文件说明

| 路径 | 用途 |
| --- | --- |
| [`SKILL.md`](SKILL.md) | Skill 的行为指令与安全约束 |
| [`scripts/ensure_fima_cli.sh`](scripts/ensure_fima_cli.sh) | 安装或定位本地 `fima` CLI |
| [`agents/openai.yaml`](agents/openai.yaml) | Skill 的展示配置 |
