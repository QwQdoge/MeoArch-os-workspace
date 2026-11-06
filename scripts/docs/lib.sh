# Shared by build-meoarch-index.sh and add-master-banner.sh
# Usage: source lib.sh ; meo_repos ; meo_md_files <repo-dir> <mode: index|banner>
MEO_PROJECTS="${MEO_PROJECTS:-$HOME/projects}"
MEO_MASTER_URL="https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md"
MEO_MARK="meoarch-master"
MEO_REPOS="MeoUI meo-kde MeoSettings OmniStore meo-ai meo-login-manager meo-repo MeoArch-os-workspace meoarch-site MeoArch-os-webside meo-ai-landing meo-api MeoArch-account downloader kde-plasma6-widgets mrbeazleyisamazing"

# Generated, vendored, runtime-data or third-party markdown never gets a banner and is not indexed.
MEO_EXCLUDE='(^|/)(node_modules|vendor|legacy|\.agents|\.Jules|prompts|knowledge|translations|po|build|\.github)/|(^|/)(LICENSE|CHANGELOG|THIRD_PARTY_NOTICES)[^/]*$|^docs/(MEOARCH_MASTER|MEOARCH_DOC_INDEX)\.md$'

meo_md_files() { # $1=repo dir, $2=index|banner
  local d="$1" name; name=$(basename "$d")
  git -C "$d" ls-files -z -- '*.md' | tr '\0' '\n' | grep -Ev "$MEO_EXCLUDE" | {
    case "$name" in
      meoarch-site) grep -Ev '^docs/' ;;                 # docs/ is generated from MeoUI by scripts/build_docs.py
      kde-plasma6-widgets) grep -Ev '/' ;;               # third-party widget docs: root files only
      *) cat ;;
    esac
  }
}
