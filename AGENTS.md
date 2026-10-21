# Agents guide

Guidance for AI coding agents working in this repository.

## Project overview

**Docker image build project** (not a PHP application) that creates production
container images for PHP, tailored for Laravel Vapor. Contains Dockerfiles,
goss tests, and CI/CD workflows.

Technologies: Dockerfile, YAML (goss/GitHub Actions), Makefile, Shell, JSON

## Repository structure

```
.github/
  workflows/ci.yml    # CI pipeline with change detection
  versions.json       # PHP version definitions (source of truth)
docker/
  8.2/, 8.3/, 8.4/, 8.5/  # Supported PHP versions (Debian trixie) - 8.5 is latest
    Dockerfile        # Build definition
    bootstrap         # Vapor runtime loop (entrypoint)
    bootstrap.php     # Vapor runtime loader
    goss.yaml         # Test specification
  8.0/, 8.1/          # Unsupported, kept for reference (not built by CI)
Makefile              # Build and test commands
```

## Commands

```bash
make build VERSION=8.5    # Build image (default: 8.5)
make test VERSION=8.5     # Build and test (default: 8.5)
```

Manual dgoss test: `GOSS_FILE=docker/8.5/goss.yaml dgoss run ghcr.io/luislavena/greek-steam:8.5 sleep infinity`

## PHP versions configuration

PHP versions defined in `.github/versions.json`. When updating:
1. Update `php_full` field in versions.json
2. Update the `ARG PHP_VERSION` default in `docker/X.Y/Dockerfile` to the same value
3. Run `make test VERSION=X.Y` to verify

**Important:** CI only builds versions whose `docker/X.Y/` folder changed. A
change to `versions.json` alone does not start a build, so always do step 2.

To rebuild for Debian security patches only (no PHP change), run the CI
workflow manually with `version` set to `all` or to one `X.Y`.

## Tools versions

When updating a tool (Eg. docker-php-extension-installer):
1. Update `*_VERSION` reference in the specific Dockerfile
2. Update SHA256 checksums of that tool
3. Run `make test VERSION=X.Y` to verify

## Dockerfile conventions

**Structure:**
- Use BuildKit syntax: `# syntax = docker/dockerfile:1`
- Take `PHP_VERSION` and `BASE_DISTRO` as `ARG` (CI passes them from versions.json)
- Numbered section comments: `# ---\n# 1. Section name`
- Use `set -eux` in all RUN commands

**Cache mounts:** Use BuildKit cache for apt with `sharing=private` (see existing Dockerfiles for pattern)

**Security:**
- Verify all downloads with SHA256: `echo "$SHA256 *file" | sha256sum -c -`
- Use `curl --fail`

**Production only:** Do not add development tools (Composer, NodeJS, etc).

## Image tests

goss files at `docker/<version>/goss.yaml` run only from `make test` on one
machine, not in CI. Categories: command, file.

```yaml
command:
  php-installed:
    exec: "php --version"
    exit-status: 0
```

## Git conventions

**Commits:** 50 char subject, capitalized, imperative mood, no period. Body at 72 chars explains what/why.

**Branches:** Use dashes: `feature-new-functionality` (not slashes)

**Worktrees:** Create in `.worktrees/` directory

## CI/CD

Pipeline detects changes in `docker/`, builds affected versions with matrix strategy,
supports amd64/arm64 (via Depot), pushes to GHCR on main. Manual dispatch available.

## Contribution policy

Bug fixes only. Features require GitHub issue discussion first.
