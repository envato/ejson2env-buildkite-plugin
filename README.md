# ejson2env Buildkite Plugin

[![tests](https://github.com/envato/ejson2env-buildkite-plugin/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/envato/ejson2env-buildkite-plugin/actions/workflows/tests.yml)

## Example

```yml
steps:
  - name: Tests
    plugins:
      - envato/ejson2env#v0.2.0:
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

## License

MIT (see [LICENSE](LICENSE))
