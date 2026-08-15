#!/usr/bin/env python3
"""Send reproducible pointer and keyboard input to the acceptance VM over QMP."""

from __future__ import annotations

import argparse
import json
import socket
import time


def qmp_execute(socket_path: str, command: str, arguments: dict | None = None) -> None:
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(5)
        client.connect(socket_path)
        stream = client.makefile("rwb", buffering=0)
        stream.readline()

        def execute(name: str, args: dict | None = None) -> None:
            payload: dict[str, object] = {"execute": name}
            if args is not None:
                payload["arguments"] = args
            stream.write(json.dumps(payload).encode() + b"\n")
            while True:
                response = json.loads(stream.readline())
                if "return" in response:
                    return
                if "error" in response:
                    raise SystemExit(response["error"])

        execute("qmp_capabilities")
        execute(command, arguments)


def send_key(socket_path: str, keys: list[str]) -> None:
    qmp_execute(
        socket_path,
        "send-key",
        {
            "keys": [{"type": "qcode", "data": key} for key in keys],
            "hold-time": 10,
        },
    )


def send_key_event(socket_path: str, key: str, modifiers: list[str] | None = None) -> None:
    modifiers = modifiers or []
    events: list[dict] = []
    for modifier in modifiers:
        events.append({
            "type": "key",
            "data": {"down": True, "key": {"type": "qcode", "data": modifier}},
        })
    events.extend([
        {
            "type": "key",
            "data": {"down": True, "key": {"type": "qcode", "data": key}},
        },
        {
            "type": "key",
            "data": {"down": False, "key": {"type": "qcode", "data": key}},
        },
    ])
    for modifier in reversed(modifiers):
        events.append({
            "type": "key",
            "data": {"down": False, "key": {"type": "qcode", "data": modifier}},
        })
    qmp_execute(socket_path, "input-send-event", {"events": events})


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--socket", required=True)
    subparsers = parser.add_subparsers(dest="action", required=True)

    click = subparsers.add_parser("click")
    click.add_argument("x", type=int)
    click.add_argument("y", type=int)
    click.add_argument("--width", type=int, default=1280)
    click.add_argument("--height", type=int, default=800)

    key = subparsers.add_parser("key")
    key.add_argument("keys", nargs="+")

    text = subparsers.add_parser("text")
    text.add_argument("value")

    args = parser.parse_args()
    if args.action == "click":
        x = round(max(0, min(args.x, args.width - 1)) * 32767 / (args.width - 1))
        y = round(max(0, min(args.y, args.height - 1)) * 32767 / (args.height - 1))
        qmp_execute(
            args.socket,
            "input-send-event",
            {"events": [
                {"type": "abs", "data": {"axis": "x", "value": x}},
                {"type": "abs", "data": {"axis": "y", "value": y}},
            ]},
        )
        time.sleep(0.25)
        qmp_execute(
            args.socket,
            "input-send-event",
            {"events": [{"type": "btn", "data": {"down": True, "button": "left"}}]},
        )
        time.sleep(0.08)
        qmp_execute(
            args.socket,
            "input-send-event",
            {"events": [{"type": "btn", "data": {"down": False, "button": "left"}}]},
        )
        return

    if args.action == "key":
        send_key_event(args.socket, args.keys[-1], args.keys[:-1])
        return

    shifted = {
        "!": "1", "@": "2", "#": "3", "$": "4", "%": "5",
        "^": "6", "&": "7", "*": "8", "(": "9", ")": "0",
        "_": "minus", "+": "equal", ":": "semicolon",
        '"': "apostrophe", "<": "comma", ">": "dot", "?": "slash",
        "|": "backslash", "~": "grave_accent",
    }
    special = {
        " ": "spc", "-": "minus", ".": "dot", "=": "equal",
        "/": "slash", ";": "semicolon", "'": "apostrophe",
        ",": "comma", "[": "leftbracket", "]": "rightbracket",
        "\\": "backslash", "`": "grave_accent",
    }
    for character in args.value:
        if character.isalpha():
            key_name = character.lower()
            modifiers = ["shift"] if character.isupper() else []
        elif character in shifted:
            key_name = shifted[character]
            modifiers = ["shift"]
        else:
            key_name = special.get(character, character)
            modifiers = []
        send_key_event(args.socket, key_name, modifiers)
        # Keep enough spacing for a busy live session to process every key.
        time.sleep(0.08)


if __name__ == "__main__":
    main()
