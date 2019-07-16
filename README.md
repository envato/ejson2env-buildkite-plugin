# ejson2env Buildkite Plugin

A Buildkite plugin to export environment variables that are stored inside an [ejson] file using [ejson2env].

## Example

```yml
steps:
  - name: Tests
    plugins:
      - envato/ejson2env#master
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
