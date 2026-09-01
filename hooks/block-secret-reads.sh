#!/bin/bash
# PreToolUse(Bash): block reader commands that touch credential stores.
# Complements the Read(...) deny rules in settings.json, which only cover the
# Read tool. Exit 2 blocks the call and shows the message to the agent.
#
# For the gated byoungs.fly.dev pages, use the wrappers instead of reading the
# token: byoungs-hub/scripts/agent-fetch.sh and agent-shot.sh read it
# internally, so it never enters an agent-visible command.
#
# Known false positive: a command whose TEXT merely mentions one of these paths
# (editing this hook, writing docs about it) is blocked even though it reads
# nothing. Use the Write/Edit tools for that; they are not matched here.

cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# credential stores, matched however the path is written (~, $HOME, absolute)
secrets='(\.ssh/|\.aws/credentials|\.sorare-keys\.zsh|\.pgpass|gogcli/keyring|/keyring/|\.agent-token)'

# commands that move file contents somewhere the agent can see
readers='(^|[;&|(]|[[:space:]])(cat|sed|awk|grep|egrep|fgrep|rg|ag|head|tail|less|more|strings|xxd|od|hexdump|base64|cut|tr|sort|uniq|nl|tee|dd|cp|scp|rsync|tar|zip|jq|python|python3|perl|ruby|node)([[:space:]]|$)'

if printf '%s' "$cmd" | grep -qE "$secrets" && printf '%s' "$cmd" | grep -qE "$readers"; then
  echo "Blocked: reads a credential store (.ssh, .aws/credentials, .sorare-keys.zsh, .pgpass, a gog keyring, or .agent-token). For byoungs.fly.dev use byoungs-hub/scripts/agent-fetch.sh or agent-shot.sh; otherwise ask Brian to read it and paste what you need." >&2
  exit 2
fi
exit 0
