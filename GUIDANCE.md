# Buildable Matomo on Wodby

This service is the [matomo](https://github.com/wodby/service-matomo) service with a build: everything in its guidance
applies, including settings, data, installation and updates. This page covers only what the build adds.

## Image

The image is built from the app's Git repository on top of the prebuilt
[wodby/matomo](https://github.com/wodby/matomo) Apache image of the selected Matomo major. The repository holds only
the app's own plugins, under `plugins/`; start from the [Matomo boilerplate](https://github.com/wodby/matomo-boilerplate).
Matomo's code comes from the base image, so new image revisions bring Matomo's updates without changing the repository.

The build copies each directory under `plugins/` into Matomo's `plugins` directory and records its name. It fails when a
directory has no `plugin.json`, or has the name of one of Matomo's own plugins, which it would replace.

## Plugins

After every deployment the **Install or update Matomo** action runs `matomo-update-app`. It installs or updates Matomo as
the matomo service does, then:

- activates every plugin from the repository;
- deactivates the plugins the repository had at the previous deployment but no longer has. The list of deployed
  plugins is kept in `config/app-plugins` on the files volume.

A plugin from the repository can't stay deactivated: the next deployment activates it again. Remove it from the
repository instead.

Plugins installed from Matomo's Marketplace work as on the matomo service: they are kept on the files volume and are not
part of the repository.
