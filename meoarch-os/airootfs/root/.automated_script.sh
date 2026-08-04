#!/usr/bin/env bash

script_cmdline() {
    local param
    for param in $(</proc/cmdline); do
        case "${param}" in
            script=*)
                echo "${param#*=}"
                return 0
                ;;
        esac
    done
}

script_sha256_cmdline() {
    local param
    for param in $(</proc/cmdline); do
        case "${param}" in
            script_sha256=*)
                echo "${param#*=}"
                return 0
                ;;
        esac
    done
}

automated_script() {
    local script script_sha256 rt
    script="$(script_cmdline)"
    script_sha256="$(script_sha256_cmdline)"

    if [[ -n "${script}" && ! -x /tmp/startup_script ]]; then
        if [[ "${script}" =~ ^((http|https|ftp|tftp)://) ]]; then
            if [[ ! "${script}" =~ ^https:// ]]; then
                printf '%s: only https:// URLs are supported for automated scripts\n' "$0"
                return 1
            fi

            if [[ -z "${script_sha256}" ]]; then
                printf '%s: downloading over https requires script_sha256 parameter for verification\n' "$0"
                return 1
            fi

            printf '%s: downloading %s\n' "$0" "${script}"
            # there's no synchronization for network availability before executing this script; to ensure the network
            # is online, we use a transient systemd service that depends on network-online.target to download the
            # script rather than manually polling the target
            systemd-run --pty --quiet -p Wants=network-online.target -p After=network-online.target \
                curl "${script}" --location --retry-connrefused --retry 10 --fail -s -o /tmp/startup_script
            rt=$?

            if [[ ${rt} -eq 0 ]]; then
                printf '%s: verifying sha256 checksum...\n' "$0"
                if ! echo "${script_sha256}  /tmp/startup_script" | sha256sum -c --status -; then
                    printf '%s: checksum verification failed!\n' "$0"
                    rm -f /tmp/startup_script
                    return 1
                fi
                printf '%s: checksum verified successfully\n' "$0"
            fi
        else
            cp "${script}" /tmp/startup_script
            rt=$?
        fi
        if [[ ${rt} -eq 0 ]]; then
            chmod +x /tmp/startup_script
            printf '%s: executing automated script\n' "$0"
            # note that script is executed when other services (like pacman-init) may be still in progress, please
            # synchronize to "systemctl is-system-running --wait" when your script depends on other services
            /tmp/startup_script
        fi
    fi
}

if [[ $(tty) == "/dev/tty1" ]]; then
    automated_script
fi
