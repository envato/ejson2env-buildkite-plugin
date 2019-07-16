#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

environment_hook="$PWD/hooks/environment"
run_environment_hook() {
  run "${environment_hook}"
}

export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_PRIVATE_KEY_ENV_KEY="EJSON_PRIVATE_KEY"
export EJSON_PRIVATE_KEY
export EJSON2ENV_TEST_MODE=true

setup_fixture() {
  local fixture="$1"
  local private_key_file="$PWD/tests/fixtures/$fixture/ejson_private_key"
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_FILE="$PWD/tests/fixtures/$fixture/ejson_file.ejson"
  if [ -f "$private_key_file" ]; then
    EJSON_PRIVATE_KEY=$(cat "$private_key_file")
  else
    echo "Fixture private key file not found"
    exit 1
  fi
}

@test "exports environment vars" {
  setup_fixture simple
  run_environment_hook
  assert_output "export A_SECRET='hoop vervain headway betimes finn allied standard softwood'"
}
