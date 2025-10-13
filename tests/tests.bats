#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

export EJSON_PRIVATE_KEY
export EJSON2ENV_TEST_MODE=true

post_checkout_hook="$PWD/hooks/post-checkout"

ejson_private_key() {
  local private_key_file="$PWD/tests/fixtures/$1/ejson_private_key"
  if [ -f "$private_key_file" ]; then
    cat "$private_key_file"
  else
    echo "Fixture private key file not found"
    exit 1
  fi
}

run_hook_with_fixture() {
  local fixture="$1"
  export EJSON_PRIVATE_KEY
  EJSON_PRIVATE_KEY=$(ejson_private_key "$fixture")
  # shellcheck disable=SC2164
  pushd "$PWD/tests/fixtures/$fixture"
  run "${post_checkout_hook}"
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
  run_hook_with_fixture simple
  assert_success
}

@test "exports multiline environment vars" {
  export EJSON2ENV_TEST_VERIFY_KEY=A_MULTILINE_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="line1
line2
line3"
  run_hook_with_fixture multiline
  assert_success
}

@test "can use a different ejson file with ejson_file option" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_FILE="ejson_build_secrets.ejson"

  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_hook_with_fixture ejson_file_specified
  assert_success
}

@test "can use a different EJSON_PRIVATE_KEY_ENV_KEY option" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_PRIVATE_KEY_ENV_KEY="MY_PRIVATE_KEY"

  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"

  export MY_PRIVATE_KEY=$(ejson_private_key simple)
  pushd "$PWD/tests/fixtures/simple"
  run "${post_checkout_hook}"
  popd
  assert_success
}

@test "fails when ejson_file doesn't exist" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_FILE="unknown.ejson"
  run_hook_with_fixture simple
  assert_failure
  assert_output "ejson_file not found at \"unknown.ejson\""
}

@test "fails when ejson_private_key_env_key is empty" {
  export BUILDKITE_PLUGIN_EJSON2ENV_EJSON_PRIVATE_KEY_ENV_KEY="MY_PRIVATE_KEY"

  unset MY_PRIVATE_KEY
  pushd "$PWD/tests/fixtures/simple"
  run "${post_checkout_hook}"
  popd
  assert_failure
  assert_output "ejson_private_key_env_key \"MY_PRIVATE_KEY\" is empty or not set"
}

@test "fails when decryption fails" {
  # incorrect private key
  export EJSON_PRIVATE_KEY="c12d273dbb5c688a25029014fffc52573cef55884a4f62ffcdc297d18f4fde7f"
  pushd "$PWD/tests/fixtures/simple"
  run "${post_checkout_hook}"
  popd
  assert_failure
  assert_line "error: could not load environment from file: could not load ejson file: couldn't decrypt message"
  assert_line "Failed to export EJSON secrets from .buildkite/secrets.ejson"
}

@test "downloads artifacts when download_ejson_file_artifacts is true" {
  export BUILDKITE_PLUGIN_EJSON2ENV_DOWNLOAD_EJSON_FILE_ARTIFACTS="true"

  # Mock buildkite-agent command
  function buildkite-agent() {
    if [[ "$1" == "artifact" ]] && [[ "$2" == "download" ]]; then
      echo "Downloaded artifacts matching $3"
      return 0
    fi
  }
  export -f buildkite-agent

  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_hook_with_fixture simple
  assert_success
  assert_line "Downloading ejson artifacts..."
  assert_line "Downloaded artifacts matching **/*.ejson"
}

@test "does not download artifacts when download_ejson_file_artifacts is false" {
  export BUILDKITE_PLUGIN_EJSON2ENV_DOWNLOAD_EJSON_FILE_ARTIFACTS="false"

  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_hook_with_fixture simple
  assert_success
  refute_line "Downloading ejson artifacts..."
}

@test "does not download artifacts when download_ejson_file_artifacts is not set" {
  export EJSON2ENV_TEST_VERIFY_KEY=A_SECRET
  export EJSON2ENV_TEST_VERIFY_VALUE="hoop vervain headway betimes finn allied standard softwood"
  run_hook_with_fixture simple
  assert_success
  refute_line "Downloading ejson artifacts..."
}
