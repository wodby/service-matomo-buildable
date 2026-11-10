# Buildable Matomo on Wodby

This service is the [matomo](https://github.com/wodby/service-matomo) service built from the app's repository: its
guidance applies to settings, data, installation and updates. This page covers what differs.

## Image

The image is built from the app's Git repository on top of [wodby/matomo-php](https://github.com/wodby/matomo-php):
PHP-FPM and Apache with the same Wodby setup as the prebuilt Matomo image, but no Matomo. The service's versions are
PHP versions. Start the repository from the [Matomo boilerplate](https://github.com/wodby/matomo-boilerplate). It holds:

- `.matomo-version`: the Matomo release to run, such as `5.14.2`, required. The build installs it with
  `matomo-install-release`, which downloads it from builds.matomo.org, checks its signature and adds Wodby's parts:
  the WodbyInstall plugin, the GeoLite database, the `.htaccess` files and the links to the files volume. Matomo 5
  releases are supported.
- `plugins/`: the app's own plugins. The build copies each directory into Matomo's `plugins` directory and records its
  name. It fails when a directory has no `plugin.json`, or has the name of one of Matomo's own plugins.

Matomo's version changes only when the repository changes it: new image revisions bring PHP, Apache and Wodby's
scripts, not a new Matomo. Upgrading Matomo means changing `.matomo-version` and deploying; the deployment updates the
database.

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
