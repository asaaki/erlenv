#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run erlenv-hooks
  assert_failure "Usage: erlenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${ERLENV_TEST_DIR}/erlenv.d"
  path2="${ERLENV_TEST_DIR}/etc/erlenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  ERLENV_HOOK_PATH="$path1:$path2" run erlenv-hooks exec
  assert_success
  assert_line 0 "${ERLENV_TEST_DIR}/erlenv.d/exec/ahoy.bash"
  assert_line 1 "${ERLENV_TEST_DIR}/erlenv.d/exec/hello.bash"
  assert_line 2 "${ERLENV_TEST_DIR}/etc/erlenv_hooks/exec/bueno.bash"
}

@test "resolves relative paths" {
  path="${ERLENV_TEST_DIR}/erlenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  ERLENV_HOOK_PATH="${HOME}/../erlenv.d" run erlenv-hooks exec
  assert_success "${ERLENV_TEST_DIR}/erlenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${ERLENV_TEST_DIR}/erlenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"

  ERLENV_HOOK_PATH="$path" run erlenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
