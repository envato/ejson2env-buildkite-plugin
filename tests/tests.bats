#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

export EJSON_PRIVATE_KEY
export EJSON2ENV_TEST_MODE=true

environment_hook="$PWD/hooks/environment"

setup_fixture() {
  local fixture="$1"
  local private_key_file="ejson_private_key"
  if [ -f "$private_key_file" ]; then
    EJSON_PRIVATE_KEY=$(cat "$private_key_file")
  else
    echo "Fixture private key file not found"
    exit 1
  fi
}

run_environment_hook_with_fixture() {
  local fixture="$1"
  pushd "$PWD/tests/fixtures/$fixture" || exit 1
  setup_fixture "$1"
  run "${environment_hook}"
  popd || exit 1
}

setup() {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_PRIVATE_KEY_ENV_KEY="EJSON_PRIVATE_KEY"
  unset BUILDKITE_PLUGIN_EJSON2ENV_EJSON_FILE
  unset EJSON2ENV_TEST_VERIFY_KEY
  unset EJSON2ENV_TEST_VERIFY_VALUE
}

@test "exports environment vars" {
  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_environment_hook_with_fixture simple
  assert_success
}

@test "exports multiline environment vars" {
  export EJSON2ENV_TEST_VERIFY_KEY=A_MULTILINE_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="line1
line2
line3"
  run_environment_hook_with_fixture multiline
  assert_success
}

@test "can use a different ejson file with EJSON_FILE" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_FILE="ejson_build_secrets.ejson"
  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_environment_hook_with_fixture ejson_file_specified
  assert_success
}
