---
name: kicad-routing
description: Route and validate KiCad PCB projects headlessly with Freerouting and Specctra DSN/SES, including routing iterations after placement edits.
---

# KiCad routing

Use the installed KiCad and Freerouting tools directly. Keep `.kicad_pcb` authoritative,
use DSN/SES for routing exchange, and evaluate the imported PCB with KiCad DRC.

## Check the installed tools

Inspect `kicad-cli version`, `kicad-cli pcb --help`, `kicad-cli pcb export --help`,
and `kicad-cli pcb drc --help` before choosing commands. Inspect Freerouting's help with:

```sh
java -Djava.awt.headless=true -jar /usr/libexec/freerouting.jar \
    --gui.enabled=false --api_server.enabled=false -da -help
```

Prefer `kicad-cli` operations when the installed version supports them.

KiCad 10 provides standalone DSN export and SES import through system Python's `pcbnew`
bindings. Inspect `pcbnew.Version()` and the docstrings of `LoadBoard`, `ExportSpecctraDSN`,
`ImportSpecctraSES`, and `SaveBoard` before using them. Use `python3`, so the distro's bindings
and Python runtime match. Do not connect to a running KiCad application.

## Prepare a candidate

Find the requested board, its project settings, custom rules, and local libraries. Copy the
complete project into a fresh candidate directory before changing placement or routing.
Preserve relative paths and the board's basename so its `.kicad_pro` and `.kicad_dru` files
remain associated. Keep the original project and earlier results unchanged.

Establish a baseline DRC report and record the pad-to-net assignments. Preserve the user's
placement constraints, locked geometry, and critical nets when making the requested edits.

## Export and route

Load the candidate with `pcbnew.LoadBoard(board_path)` and check that it returns a board.
Export using the explicit-board overload `pcbnew.ExportSpecctraDSN(board, dsn_path)` and
check its boolean return value and the output file. The filename-only overload needs an
editor frame and is unsuitable for this headless workflow.

Run Freerouting with explicit input and output paths. For example:

```sh
java -Djava.awt.headless=true -jar /usr/libexec/freerouting.jar \
    --gui.enabled=false --api_server.enabled=false -da \
    -de candidate/board.dsn -do candidate/board.ses -mp 20 -mt 4
```

Adjust passes, threads, and routing settings to the task and available resources. Check the
exit status and generated session before importing it. Export a fresh DSN after changing
placement or board geometry; reuse an earlier SES only with compatible, unchanged geometry.

## Import and validate

Make a fresh copy of the candidate project for the routed result, retaining the board's
basename and companion files. Load that copy, call `pcbnew.ImportSpecctraSES(board, ses_path)`,
and check its return value before saving. Save only the routed copy with
`pcbnew.SaveBoard(output_path, board, True)` and check the result. The third argument skips
rewriting project settings. On a failed import, do not save or treat a partial result as valid;
report the failure and inspect the installed API before retrying.

Reopen the saved PCB and compare pad-to-net assignments with the baseline. Check that the
requested placement constraints and protected geometry still hold. Run KiCad's own DRC:

```sh
kicad-cli pcb drc --format json --severity-all --refill-zones \
    --exit-code-violations --output routed/drc.json routed/board.kicad_pcb
```

Inspect the installed command's help for flag support. Without `--save-board`, zone refill
is used for checking and does not rewrite the PCB. Exit code 0 means no reported violations;
5 means violations were found. Inspect the JSON's `violations` and `unconnected_items`;
other exit codes indicate a command failure. A generated SES alone does not establish success.

Compare results with the baseline, report remaining violations and unrouted connections,
and identify the routed PCB and report paths. Only perform further optimization iterations
when requested, using separate candidate projects and preserving the best validated result.

## References

- [KiCad CLI documentation](https://docs.kicad.org/10.0/en/cli/cli.html)
- [KiCad Python bindings](https://docs.kicad.org/doxygen-python-10.0/namespacepcbnew.html)
- [Freerouting CLI documentation](https://github.com/freerouting/freerouting/blob/v2.5.0/docs/command_line_arguments.md)
