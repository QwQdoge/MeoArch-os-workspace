from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
INSTALL = ROOT / "scripts" / "install.sh"


class RemoteDesktopBootstrapContractTests(unittest.TestCase):
    def test_remote_install_uses_signed_package_repository(self) -> None:
        source = INSTALL.read_text()
        self.assertIn("packages.meoarch.org", source)
        self.assertIn("meo-keyring", source)
        self.assertIn("meo-mirrorlist", source)
        self.assertIn("meo-channel-stable", source)
        self.assertIn("meo-release", source)
        self.assertIn("meo-core-meta", source)
        self.assertIn("meo-recommended-meta", source)
        self.assertIn("pacman -Syu", source)

    def test_remote_install_never_fetches_component_source(self) -> None:
        source = INSTALL.read_text()
        forbidden = (
            "git clone",
            "QwQdoge/meo-kde.git",
            "QwQdoge/MeoUI.git",
            "cmake -S",
            "makepkg",
        )
        for token in forbidden:
            with self.subTest(token=token):
                self.assertNotIn(token, source)

    def test_public_bootstrap_material_is_hash_pinned(self) -> None:
        source = INSTALL.read_text()
        self.assertIn("meo.gpg", source)
        self.assertIn("meo-trusted", source)
        self.assertIn("meo-revoked", source)
        self.assertIn("sha256sum", source)
        self.assertIn("67912eaaab10f6b57658c9aad9854bd8023cc99e3cb99a2320d5c175ec87e5e9", source)

    def test_repository_configuration_requires_trusted_signatures(self) -> None:
        source = INSTALL.read_text()
        self.assertIn("SigLevel = Required TrustedOnly", source)
        self.assertIn("Include = /etc/pacman.d/meo-channel.conf", source)


if __name__ == "__main__":
    unittest.main()
