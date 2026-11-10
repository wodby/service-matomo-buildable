# Builds Matomo from the app repository on top of the prebuilt wodby/matomo
# image: the release named in .matomo-version replaces the image's Matomo, and
# the plugins in plugins/ are added and listed in .app-plugins, so the
# post-deployment action activates them. Without .matomo-version the build
# keeps the image's Matomo.
ARG WODBY_BASE_IMAGE
FROM ${WODBY_BASE_IMAGE}

ARG COPY_FROM

COPY --chown=wodby:wodby ${COPY_FROM}/ /tmp/app/

USER root

RUN set -e; \
    if [ -f /tmp/app/.matomo-version ]; then \
        version=$(tr -d ' \t\r\n' < /tmp/app/.matomo-version); \
        if ! command -v matomo-use-release > /dev/null; then \
            echo "This Matomo image can't use the version in .matomo-version; update the service to a newer revision" >&2; \
            exit 1; \
        fi; \
        apk add --no-cache -t .gpg gnupg; \
        matomo-use-release "${version}"; \
        apk del --purge .gpg; \
    else \
        echo "No .matomo-version in the repository, so the build keeps Matomo ${MATOMO_VER}"; \
    fi; \
    : > "${APP_ROOT}/.app-plugins"; \
    for dir in /tmp/app/plugins/*/; do \
        [ -d "${dir}" ] || continue; \
        name=$(basename "${dir}"); \
        if [ ! -f "${dir}plugin.json" ]; then \
            echo "plugins/${name} has no plugin.json, so it is not a Matomo plugin" >&2; \
            exit 1; \
        fi; \
        if [ -e "${APP_ROOT}/plugins/${name}" ]; then \
            echo "plugins/${name} has the name of one of Matomo's own plugins; rename it" >&2; \
            exit 1; \
        fi; \
        cp -a "${dir%/}" "${APP_ROOT}/plugins/${name}"; \
        echo "${name}" >> "${APP_ROOT}/.app-plugins"; \
    done; \
    chown wodby:wodby "${APP_ROOT}/.app-plugins"; \
    rm -rf /tmp/app; \
    printf '%s\n' \
        '#!/usr/bin/env bash' \
        '# Installs or updates Matomo, activates the plugins from the app repository' \
        '# and deactivates the ones removed from it since the last deployment.' \
        'set -eo pipefail' \
        'matomo-update' \
        'cd "${APP_ROOT}"' \
        'mapfile -t plugins < .app-plugins' \
        'if [[ ${#plugins[@]} -gt 0 ]]; then' \
        '    php console plugin:activate --no-interaction "${plugins[@]}"' \
        'fi' \
        'deployed="${FILES_DIR}/config/app-plugins"' \
        'if [[ -f "${deployed}" ]]; then' \
        '    while IFS= read -r name; do' \
        '        if [[ -n "${name}" ]] && ! grep -qxF "${name}" .app-plugins; then' \
        '            echo "Deactivating ${name}, which the app repository no longer has"' \
        '            php console plugin:deactivate --no-interaction "${name}" || echo "Could not deactivate ${name}" >&2' \
        '        fi' \
        '    done < "${deployed}"' \
        'fi' \
        'cp .app-plugins "${deployed}"' \
        > /usr/local/bin/matomo-update-app; \
    chmod +x /usr/local/bin/matomo-update-app; \
    echo "App plugins: $(paste -sd ' ' "${APP_ROOT}/.app-plugins")"

USER wodby
