#!/usr/bin/env bash
# Seed ArchISO's pacstrap root with only the public trust material needed to
# validate the Arch and Meo package repositories.  This is not a copy of the
# host pacman keyring and it must never create or retain a private key.
set -Eeuo pipefail

usage() {
  echo "Usage: $0 STAGED_PROFILE ISO_BOOTSTRAP_DIR PROVENANCE_FILE" >&2
}

[ "$#" -eq 3 ] || { usage; exit 2; }
profile_dir="$1"
bootstrap_dir="$2"
provenance_file="$3"
seed_dir="${profile_dir}/airootfs/etc/pacman.d/gnupg"

[ -d "${profile_dir}/airootfs" ] || {
  echo "Staged ArchISO profile has no airootfs: ${profile_dir}" >&2
  exit 2
}
[ -d "${bootstrap_dir}" ] || {
  echo "ISO bootstrap directory is missing: ${bootstrap_dir}" >&2
  exit 2
}
[ ! -e "${seed_dir}" ] || {
  echo "Refusing a stale build keyring destination: ${seed_dir}" >&2
  exit 2
}

arch_keyring_dir="/usr/share/pacman/keyrings"
for source in \
  "${arch_keyring_dir}/archlinux.gpg" \
  "${arch_keyring_dir}/archlinux-trusted" \
  "${arch_keyring_dir}/archlinux-revoked" \
  "${bootstrap_dir}/meo.gpg" \
  "${bootstrap_dir}/meo-trusted" \
  "${bootstrap_dir}/meo-revoked"; do
  [ -f "${source}" ] && [ ! -L "${source}" ] && [ -s "${source}" ] || {
    echo "Required public keyring input is missing or unsafe: ${source}" >&2
    exit 3
  }
done

install -d -m 700 "${seed_dir}"
# pacman-key checks this compatibility file before libgpgme opens the public
# ring.  It deliberately starts empty: no pacman master key is generated.
install -m 644 /dev/null "${seed_dir}/pubring.gpg"
install -m 644 /dev/null "${seed_dir}/gpg.conf"

# GnuPG's agent socket has a short Unix-domain path limit.  The staged profile
# can be much deeper than that in a rootless ArchISO build, so make the public
# ring in a short disposable home and copy only its public artifacts afterward.
gpg_home="$(mktemp -d /tmp/meo-archiso-keyring.XXXXXX)"
cleanup_gpg_home() {
  gpgconf --homedir "${gpg_home}" --kill gpg-agent >/dev/null 2>&1 || true
  find "${gpg_home}" -mindepth 1 -delete 2>/dev/null || true
  rmdir "${gpg_home}" 2>/dev/null || true
}
trap cleanup_gpg_home EXIT
install -m 644 /dev/null "${gpg_home}/pubring.gpg"
install -m 644 /dev/null "${gpg_home}/gpg.conf"

gpg_args=(gpg --homedir "${gpg_home}" --batch --no-options --no-auto-key-retrieve --auto-key-locate clear)
"${gpg_args[@]}" --import "${arch_keyring_dir}/archlinux.gpg"
"${gpg_args[@]}" --import-ownertrust "${arch_keyring_dir}/archlinux-trusted"
"${gpg_args[@]}" --import "${bootstrap_dir}/meo.gpg"
"${gpg_args[@]}" --import-ownertrust "${bootstrap_dir}/meo-trusted"

# The shipped *.revoked files are fingerprint lists, not OpenPGP bundles.  Do
# not retain a revoked archive key merely because it was present in a public
# keyring source.
for revoked in "${arch_keyring_dir}/archlinux-revoked" "${bootstrap_dir}/meo-revoked"; do
  while IFS= read -r fingerprint; do
    [ -z "${fingerprint}" ] && continue
    [[ "${fingerprint}" =~ ^[0-9A-F]{40}$ ]] || {
      echo "Invalid revoked-key fingerprint in ${revoked}" >&2
      exit 3
    }
    "${gpg_args[@]}" --yes --delete-keys "${fingerprint}" >/dev/null 2>&1 || true
  done <"${revoked}"
done

if "${gpg_args[@]}" --with-colons --list-secret-keys | grep -q '^sec:'; then
  echo "Refusing a build keyring that contains a private key." >&2
  exit 4
fi
"${gpg_args[@]}" --check-trustdb >/dev/null

# GnuPG writes a temporary public-ring backup during import.  It is redundant
# and could predate the revoked-key filtering above, so clean it in the
# disposable home before copying only the public ring and trust database.
find "${gpg_home}" -maxdepth 1 -type f -name 'pubring.*~' -delete
if [ -d "${gpg_home}/private-keys-v1.d" ]; then
  [ -z "$(find "${gpg_home}/private-keys-v1.d" -mindepth 1 -print -quit)" ] || {
    echo "Refusing a build keyring with private-key material." >&2
    exit 4
  }
  rmdir "${gpg_home}/private-keys-v1.d"
fi
install -m 644 "${gpg_home}/pubring.gpg" "${seed_dir}/pubring.gpg"
install -m 600 "${gpg_home}/trustdb.gpg" "${seed_dir}/trustdb.gpg"
find "${seed_dir}" -mindepth 1 -type f -exec chmod 644 {} +
chmod 600 "${seed_dir}/trustdb.gpg"
chmod 700 "${seed_dir}"
public_ring="${seed_dir}/pubring.gpg"
[ -s "${public_ring}" ] || {
  echo "Generated public package keyring is missing: ${public_ring}" >&2
  exit 4
}

key_count="$("${gpg_args[@]}" --with-colons --list-keys | awk -F: '$1 == "pub" { count += 1 } END { print count + 0 }')"
meo_fingerprint="ACCF58C005D467A0C8633806F302FD51C40616AA"
"${gpg_args[@]}" --with-colons --list-keys "${meo_fingerprint}" | grep -q '^pub:' || {
  echo "Meo package archive public key is absent from build seed." >&2
  exit 4
}

install -d "$(dirname -- "${provenance_file}")"
{
  printf 'kind\tvalue\n'
  printf 'archlinux-keyring\t%s\n' "$(pacman -Q archlinux-keyring 2>/dev/null || printf unavailable)"
  printf 'meo-archive-fingerprint\t%s\n' "${meo_fingerprint}"
  printf 'public-key-count\t%s\n' "${key_count}"
  printf 'private-key-count\t0\n'
  for source in \
    "${arch_keyring_dir}/archlinux.gpg" \
    "${arch_keyring_dir}/archlinux-trusted" \
    "${arch_keyring_dir}/archlinux-revoked" \
    "${bootstrap_dir}/meo.gpg" \
    "${bootstrap_dir}/meo-trusted" \
    "${bootstrap_dir}/meo-revoked" \
    "${public_ring}" \
    "${seed_dir}/trustdb.gpg"; do
    printf 'sha256\t%s\n' "$(sha256sum "${source}" | awk '{print $1 "  " $2}')"
  done
} >"${provenance_file}"

echo "PASS: staged public Arch and Meo build keyrings (${key_count} public keys)"
