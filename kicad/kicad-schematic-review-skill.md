---
name: kicad-schematic-review
description: Audit KiCad schematics before PCB placement using ERC, netlist inspection, and datasheet-based electrical review.
---

# KiCad schematic review

Review the circuit before PCB placement. Use KiCad's electrical rule checker and exported
connectivity as evidence, then assess the design against its requirements and component
datasheets. Keep source files unchanged unless the user requests fixes.

## Establish the inputs

Find the root `.kicad_sch`, its child sheets, `.kicad_pro`, and any project-specific symbol
libraries. Use the root schematic so hierarchical sheets and labels are included. Identify
the intended supply voltages, loads, interfaces, and operating conditions from the project
and user requirements. Record missing information rather than assuming it.

Identify exact component part numbers and packages. Consult manufacturer datasheets for
pin assignments, operating limits, and application requirements. Cite the relevant revision
and section when a finding depends on a datasheet. Mark checks that cannot be completed
because part identification, documentation, or requirements are missing.

## Generate review evidence

Inspect `kicad-cli version`, `kicad-cli sch erc --help`, and the relevant `sch export` help
before choosing commands. Make a complete working copy of the project in a fresh review
directory, preserving basenames, child sheets, libraries, and relative paths. Run KiCad on
that copy: even ERC can write a `.kicad_prl` sidecar. Keep the original project untouched and
write reports and exports without overwriting previous results. For example, with the copied
root schematic at `review/project/project.kicad_sch`:

```sh
kicad-cli sch erc --format json --severity-all --exit-code-violations \
    --output review/erc.json review/project/project.kicad_sch
kicad-cli sch export netlist --format kicadxml \
    --output review/netlist.xml review/project/project.kicad_sch
kicad-cli sch export svg --output review/sheets/ review/project/project.kicad_sch
```

Check each command's exit status and output. ERC exit code 0 means no reported violations;
5 means violations were found and the report should be reviewed. Other exit codes indicate
a command failure. Keep excluded violations visible and explain their relevance; do not
change ERC severities or add exclusions to make the report pass.

Inspect the native schematic and exported netlist for actual connectivity. Use rendered
sheets to understand circuit blocks and annotations when image viewing is available. If
only textual inspection is possible, state that limitation. Report unresolved libraries
or missing sheets as gaps in the review, rather than drawing conclusions from incomplete
exports. A clean ERC report alone does not establish that the circuit will function.

## Review the circuit

Follow power and signal paths across sheets. Focus checks on the design's actual components
and requirements:

- Check supply and logic voltage compatibility, power-pin connections, regulator input/output
  requirements, polarity, and component voltage/current/power ratings under stated conditions.
- Check decoupling and bulk capacitance, regulator stability requirements, pull-ups and
  pull-downs, reset and boot states, clocks, and programming/debug access against datasheets.
- Verify connector pinouts, signal direction, net labels, hierarchical ports, and intentional
  no-connects. Check symbol pin numbers and assigned footprint pad mappings against the
  selected package when the required libraries are available.
- Assess protection, grounding, analog references, and interface termination where the
  application requires them. Check calculations and distinguish normal operating limits
  from absolute maximum ratings.

Separate confirmed connectivity errors from plausible electrical concerns and unanswered
questions. Describe the condition that makes each concern relevant. Do not infer that
decoupling placement, return paths, thermal performance, or routing constraints are satisfied
from the schematic alone; record these as requirements for the later PCB layout review.

## Report findings

Lead with actionable findings ordered by impact. For each, identify the sheet, component
references, pins or nets, supporting evidence, expected consequence, and a suggested fix or
specific question. Distinguish confirmed issues from unverified concerns.

Summarize ERC errors, warnings, and exclusions, including any checks or exports that failed.
List remaining assumptions, missing evidence, and the report/export paths. Hand off relevant
placement and routing constraints without starting PCB edits or autorouting as part of the
audit. If no issues are found, state what was checked and the remaining limits of the review.

## References

- [KiCad schematic ERC and export commands](https://docs.kicad.org/10.0/en/cli/cli.html)
- [KiCad schematic documentation](https://docs.kicad.org/10.0/en/eeschema/eeschema.html)
