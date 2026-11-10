# Buildable Matomo service for Kubernetes on Wodby

Run Matomo with your own plugins on Kubernetes with Wodby.

This repository defines the Wodby service manifest for Matomo built from your
Git repository. Your repository pins Matomo's version and holds your plugins;
the build installs them on [`wodby/matomo-php`](https://github.com/wodby/matomo-php),
which brings PHP, Apache and Wodby's setup for Matomo.

- [Browse Wodby services](https://wodby.com/services)
- [Wodby service documentation](https://wodby.com/docs/2.0/services/)
- [Service manifest reference](https://wodby.com/docs/2.0/services/template/)

## Service overview

| Property | Manifest configuration |
| --- | --- |
| Service name | `matomo-buildable` |
| Based on | [`matomo`](https://github.com/wodby/service-matomo): links, settings, volumes, cron and resources |
| Versions | PHP `8.4` |
| Type | Application service |
| Image | Built from your repository on top of [`wodby/matomo-php`](https://github.com/wodby/matomo-php) |
| Application build | Matomo release from `.matomo-version` and your plugins under `plugins/`; start from the [Matomo boilerplate](https://github.com/wodby/matomo-boilerplate) |
| Operations | 1 action: installs or updates Matomo, then activates your plugins |

To have Wodby keep Matomo up to date instead, use the [Matomo service](https://github.com/wodby/service-matomo): it
needs no repository or build.

## Use this service

Reference `matomo-buildable` from a Wodby stack. A service is a reusable component
and does not deploy by itself. The stack defines its links, settings, versions,
resources, and relationship to the rest of the application.

## Maintain a custom version

1. Fork this repository.
2. Edit the service manifest and referenced files.
3. Import the repository as a [Git-backed service](https://wodby.com/docs/2.0/services/create/#create-a-git-backed-service).
4. Reference the service from a stack manifest.

Validate the manifest with:

```bash
wodby service validate-manifest service.yml --org <org-id>
```

See the [service manifest reference](https://wodby.com/docs/2.0/services/template/) and the [managed services index](https://github.com/wodby/services).
