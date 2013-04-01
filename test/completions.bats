#!/usr/bin/env bats

load test_helper

create_command() {
  bin="${ERLENV_TEST_DIR}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "command with no completion support" {
  create_command "erlenv-hello" "#!$BASH
    echo hello"
  run erlenv-completions hello
  assert_success ""
}

@test "command with completion support" {
  create_command "erlenv-hello" "#!$BASH
# provide erlenv completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"
  run erlenv-completions hello
  assert_success "hello"
}

@test "forwards extra arguments" {
  create_command "erlenv-hello" "#!$BASH
# provide erlenv completions
if [[ \$1 = --complete ]]; then
  shift 1
  while [[ \$# -gt 0 ]]; do
    echo \$1
    shift 1
  done
else
  exit 1
fi"
  run erlenv-completions hello happy world
  assert_success
  assert_line 0 "happy"
  assert_line 1 "world"
  refute_line 2
}
