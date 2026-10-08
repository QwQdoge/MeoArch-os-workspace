# Terminal integration into the canonical System AI Router

The terminal contribution uses the existing `MeoAi::CapabilityRegistry`,
`PolicyEngine`, caller-bound permissions, and `TerminalWorkspaceExecutor`.
There is one router executable and one capability registry.

`terminal.workspace.run` requires an explicitly granted workspace and
bubblewrap isolation. Network access is a separate permission. The sandbox
has a clean environment, bounded captured output, and a command deadline.
The shell runs without login/startup profiles. Host shell execution is not
exposed, and the workspace terminal remains unavailable to external MCP.

`TerminalPolicy` supplies explanatory risk labels; its regular expressions
are not an authorization or sandbox boundary. A normal label does not prove
that a shell command is read-only. The canonical router remains responsible
for permissions and exact-request confirmations for capabilities requiring them.

`--search-tools QUERY` searches metadata from the same canonical registry.
Discovery does not grant permissions or make placeholder capabilities executable.

This integration preserves the current architecture while absorbing terminal
risk classification, catalog search, and incremental bounded output capture
from the historical terminal PR. It does not install a second host command runner.
