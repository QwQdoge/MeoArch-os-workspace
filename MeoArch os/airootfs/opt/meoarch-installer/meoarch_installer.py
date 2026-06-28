#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path

import gi

gi.require_version("Gtk", "4.0")
from gi.repository import Gio, Gtk


CONFIG_PREVIEW = {
    "hostname": "meoarch",
    "locale_config": {
        "kb_layout": "us",
        "sys_enc": "UTF-8",
        "sys_lang": "en_US",
    },
    "mirror_config": {
        "mirror_regions": {
            "Worldwide": ["https://geo.mirror.pkgbuild.com/$repo/os/$arch"]
        }
    },
    "timezone": "UTC",
}


class InstallerWindow(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)
        self.set_title("MeoArch Installer")
        self.set_default_size(980, 640)

        self.status = Gtk.Label(label="Ready")
        self.status.set_xalign(0)

        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self.stack.set_hexpand(True)
        self.stack.set_vexpand(True)

        self.steps = [
            ("welcome", "Welcome", self._welcome_page()),
            ("disk", "Disk", self._placeholder_page("Disk layout", "Select the install target and partition strategy.")),
            ("user", "User", self._placeholder_page("User account", "Collect hostname, username, password, and shell.")),
            ("profile", "Profile", self._placeholder_page("Desktop profile", "Choose packages, graphics stack, and default services.")),
            ("review", "Review", self._review_page()),
            ("install", "Install", self._install_page()),
        ]

        self.sidebar = Gtk.ListBox()
        self.sidebar.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.sidebar.set_size_request(220, -1)

        for page_id, title, page in self.steps:
            row = Gtk.ListBoxRow()
            row.set_child(Gtk.Label(label=title, xalign=0))
            self.sidebar.append(row)
            self.stack.add_titled(page, page_id, title)

        self.sidebar.connect("row-selected", self._on_step_selected)

        body = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        body.append(self.sidebar)
        body.append(self.stack)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        root.append(self._header())
        root.append(body)
        root.append(self._footer())
        self.set_child(root)
        self.sidebar.select_row(self.sidebar.get_row_at_index(0))

    def _header(self):
        header = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        header.set_margin_top(28)
        header.set_margin_bottom(20)
        header.set_margin_start(32)
        header.set_margin_end(32)

        title = Gtk.Label(label="MeoArch Installer")
        title.set_xalign(0)
        title.add_css_class("title-1")

        subtitle = Gtk.Label(label="Cage kiosk shell for a future archinstall-backed graphical workflow")
        subtitle.set_xalign(0)
        subtitle.add_css_class("dim-label")

        header.append(title)
        header.append(subtitle)
        return header

    def _footer(self):
        footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        footer.set_margin_top(14)
        footer.set_margin_bottom(18)
        footer.set_margin_start(32)
        footer.set_margin_end(32)

        quit_button = Gtk.Button(label="Exit")
        quit_button.connect("clicked", lambda *_: self.get_application().quit())

        footer.append(self.status)
        footer.append(quit_button)
        return footer

    def _welcome_page(self):
        box = self._page_box()
        title = Gtk.Label(label="Install MeoArch")
        title.set_xalign(0)
        title.add_css_class("title-2")

        text = Gtk.Label(
            label=(
                "This is the first graphical shell. It is intentionally non-destructive: "
                "the UI can collect choices and generate an archinstall config before "
                "we wire in real disk operations."
            )
        )
        text.set_xalign(0)
        text.set_wrap(True)

        box.append(title)
        box.append(text)
        return box

    def _placeholder_page(self, title_text, body_text):
        box = self._page_box()
        title = Gtk.Label(label=title_text)
        title.set_xalign(0)
        title.add_css_class("title-2")

        body = Gtk.Label(label=body_text)
        body.set_xalign(0)
        body.set_wrap(True)

        note = Gtk.Label(label="Next step: replace this page with real controls and validation.")
        note.set_xalign(0)
        note.add_css_class("dim-label")

        box.append(title)
        box.append(body)
        box.append(note)
        return box

    def _review_page(self):
        box = self._page_box()
        title = Gtk.Label(label="archinstall config preview")
        title.set_xalign(0)
        title.add_css_class("title-2")

        preview = Gtk.TextView()
        preview.set_editable(False)
        preview.set_monospace(True)
        preview.set_vexpand(True)
        preview.get_buffer().set_text(json.dumps(CONFIG_PREVIEW, indent=2))

        box.append(title)
        box.append(preview)
        return box

    def _install_page(self):
        box = self._page_box()
        title = Gtk.Label(label="Installation runner")
        title.set_xalign(0)
        title.add_css_class("title-2")

        warning = Gtk.Label(
            label=(
                "The runner is disabled in this framework build. When the workflow is ready, "
                "this page should write a validated config and call archinstall in guided mode."
            )
        )
        warning.set_xalign(0)
        warning.set_wrap(True)

        dry_run = Gtk.Button(label="Write config preview")
        dry_run.connect("clicked", self._write_preview)

        box.append(title)
        box.append(warning)
        box.append(dry_run)
        return box

    def _page_box(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18)
        box.set_margin_top(24)
        box.set_margin_bottom(24)
        box.set_margin_start(32)
        box.set_margin_end(32)
        box.set_hexpand(True)
        box.set_vexpand(True)
        return box

    def _on_step_selected(self, _listbox, row):
        if row is None:
            return
        page_id = self.steps[row.get_index()][0]
        self.stack.set_visible_child_name(page_id)

    def _write_preview(self, _button):
        output_path = Path("/tmp/meoarch-archinstall-preview.json")
        output_path.write_text(json.dumps(CONFIG_PREVIEW, indent=2) + "\n", encoding="utf-8")
        self.status.set_text(f"Wrote {output_path}")


class InstallerApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="os.meoarch.Installer", flags=Gio.ApplicationFlags.DEFAULT_FLAGS)

    def do_activate(self):
        window = InstallerWindow(self)
        window.present()


def main():
    if os.geteuid() != 0:
        print("warning: installer is normally expected to run as root in the live ISO", file=sys.stderr)
    return InstallerApp().run(sys.argv)


if __name__ == "__main__":
    raise SystemExit(main())

