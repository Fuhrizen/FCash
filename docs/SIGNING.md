# Release signing

FCash release signing is handled by HEMTT during the release build.

Run:

```bash
docker compose run --rm --build build
```

The single Compose service performs validation, runs `hemtt release`, verifies that the release contains a PBO, BISIGN and BIKEY, and copies the finished release into `dist/`.

No interactive key-generation step is required.

HEMTT uses the signing authority configured in `.hemtt/project.toml`:

```toml
[signing]
authority = "fuhrizen"
version = 3
```

For this configuration HEMTT creates the signing material needed for the release automatically. The generated public `.bikey` is included in the release `keys/` directory and each PBO receives a matching `.bisign` file.

Server operators place the `.bikey` in the Arma 3 server `keys` directory. Clients receive the PBO and matching BISIGN as part of the mod.

The build container is ephemeral when invoked with `docker compose run --rm`; only the repository and `dist/` output remain on the host.
