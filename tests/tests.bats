#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

export EJSON_PRIVATE_KEY
export EJSON2ENV_TEST_MODE=true

pre_command_hook="$PWD/hooks/pre-command"

ejson_private_key() {
  local private_key_file="$PWD/tests/fixtures/$1/ejson_private_key"
  if [ -f "$private_key_file" ]; then
    cat "$private_key_file"
  else
    echo "Fixture private key file not found"
    exit 1
  fi
}

run_pre_commmand_hook_with_fixture() {
  local fixture="$1"
  export EJSON_PRIVATE_KEY
  EJSON_PRIVATE_KEY=$(ejson_private_key "$fixture")
  pushd "$PWD/tests/fixtures/$fixture" || exit 1
  run "${pre_command_hook}"
  popd || exit 1
}

setup() {
  unset BUILDKITE_PLUGIN_EJSON2ENV_EJSON_PRIVATE_KEY_ENV_KEY
  unset EJSON_PRIVATE_KEY
  unset EJSON2ENV_TEST_VERIFY_KEY
  unset EJSON2ENV_TEST_VERIFY_VALUE
}

@test "exports simple environment vars" {
  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_pre_commmand_hook_with_fixture simple
  assert_success
}

@test "exports multiline environment vars" {
  export EJSON2ENV_TEST_VERIFY_KEY=A_MULTILINE_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="line1
line2
line3"
  run_pre_commmand_hook_with_fixture multiline
  assert_success
}

@test "can use a different ejson file with ejson_file option" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_FILE="ejson_build_secrets.ejson"

  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_pre_commmand_hook_with_fixture ejson_file_specified
  assert_success
}

@test "can use a different EJSON_PRIVATE_KEY_ENV_KEY option" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_PRIVATE_KEY_ENV_KEY="MY_PRIVATE_KEY"

  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"

  export MY_PRIVATE_KEY=$(ejson_private_key simple)
  pushd "$PWD/tests/fixtures/simple" || exit 1
  run "${pre_command_hook}"
  popd || exit 1
  assert_success
}

@test "exits when ejson_file doesn't exist" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_FILE="unknown.ejson"
  run_pre_commmand_hook_with_fixture simple
  assert_failure
  assert_output "ejson_file not found at \"unknown.ejson\""
}

@test "exits when ejson_file doesn't exist" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_PRIVATE_KEY_ENV_KEY="MY_PRIVATE_KEY"

  unset MY_PRIVATE_KEY
  pushd "$PWD/tests/fixtures/simple" || exit 1
  run "${pre_command_hook}"
  popd || exit 1
  assert_failure
  assert_output "ejson_private_key_env_key \"MY_PRIVATE_KEY\" is empty or not set"
}

@test "fails when decryption fails" {
  # incorrect private key
  export EJSON_PRIVATE_KEY="c12d273dbb5c688a25029014fffc52573cef55884a4f62ffcdc297d18f4fde7f"
  pushd "$PWD/tests/fixtures/simple" || exit 1
  run "${pre_command_hook}"
  popd || exit 1
  assert_failure
  assert_line "error: could not load ejson file: couldn't decrypt message"
  assert_line "Failed to export EJSON secrets from .buildkite/secrets.ejson"
}
