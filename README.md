# ejson2env Buildkite Plugin

A Buildkite plugin for exporting environment variables stored inside [ejson](https://github.com/Shopify/ejson) files using [ejson2env](https://github.com/Shopify/ejson2env).

[![tests](https://github.com/envato/ejson2env-buildkite-plugin/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/envato/ejson2env-buildkite-plugin/actions/workflows/tests.yml)

## Example

```yml
steps:
  - name: Tests
    plugins:
      - envato/ejson2env#v0.3.0:
          ejson_file: .buildkite/secrets.ejson
          ejson_private_key_env_key: EJSON_PRIVATE_KEY
```

## Configuration

### `ejson_file` (optional)

The EJSON file to decrypt and export with `ejson2env`.

Default: `.buildkite/secrets.ejson`

### `ejson_private_key_env_key` (optional)

The environment variable containing the private key to decrypt the EJSON file.

Default: `EJSON_PRIVATE_KEY`

### `download_ejson_file_artifacts` (optional)

Download ejson artifacts (`**/*.ejson`) from previous build steps before decryption. This is useful when ejson files are generated or stored as artifacts in earlier pipeline steps.

Default: `false`

Example:

```yml
steps:
  - name: Tests
    plugins:
      - envato/ejson2env#v0.3.0:
          download_ejson_file_artifacts: true
```

## License

MIT (see [LICENSE](LICENSE))
