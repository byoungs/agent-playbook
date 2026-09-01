#!/usr/bin/env python3
"""PreToolUse(Bash): block force pushes.

Replaces an inline regex (`git push.*(--force|--force-with-lease|-f )`) that
missed six real force-push forms: `git -C <path> push --force`, `git -c k=v push
--force`, a trailing `-f`, a `+refspec`, and abbreviated long options like
`--fo`. It also fired on the string "git push --force" inside a quoted commit
message.

This tokenizes instead: split the command into segments, shlex each one, skip
git's global options (including the ones that take a value), confirm the
subcommand is actually `push`, then look for force in any of its spellings.

Exit 2 blocks the call and shows the message to the agent.
"""
import json
import re
import shlex
import sys

# git global options that consume the following token as their value
GLOBAL_OPTS_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace",
                          "--exec-path", "--super-prefix", "--config-env"}
# long options that mean force; an abbreviation of any of these counts too,
# since git accepts any unambiguous prefix
FORCE_LONG = ("--force", "--force-with-lease", "--force-if-includes")


def segments(command):
    """Split a shell command into individually-parseable pieces."""
    return re.split(r"[;&|\n]+", command)


def is_force_token(tok):
    if tok.startswith("--"):
        # exact, or an abbreviation git would accept (--fo, --forc, ...)
        return any(full.startswith(tok) for full in FORCE_LONG) or \
               tok.startswith("--force")
    if tok.startswith("-") and len(tok) > 1:
        # short flag, possibly bundled: -f, -fu, -uf
        return "f" in tok[1:]
    # a leading + on a refspec is a force push
    return tok.startswith("+") and len(tok) > 1


def has_force_push(segment):
    try:
        toks = shlex.split(segment)
    except ValueError:
        toks = segment.split()
    if not toks:
        return False

    for i, tok in enumerate(toks):
        if tok != "git" and not tok.endswith("/git"):
            continue
        j = i + 1
        # walk past git's own global options to reach the subcommand
        while j < len(toks):
            t = toks[j]
            if not t.startswith("-"):
                break
            if t in GLOBAL_OPTS_WITH_VALUE:
                j += 2
            else:
                j += 1
        if j < len(toks) and toks[j] == "push":
            if any(is_force_token(t) for t in toks[j + 1:]):
                return True
    return False


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)
    command = payload.get("tool_input", {}).get("command", "")
    if not command:
        sys.exit(0)

    if any(has_force_push(seg) for seg in segments(command)):
        print("Force push blocked. Suggest the command to Brian instead of "
              "running it.", file=sys.stderr)
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
