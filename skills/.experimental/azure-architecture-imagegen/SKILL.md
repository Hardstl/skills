---
name: azure-architecture-imagegen
description: Generate Azure architecture diagrams with imagegen in a Microsoft Learn / Azure Architecture Center visual style. Use when Codex is asked to create, ideate, mock up, or refine Azure cloud architecture diagrams, reference architecture visuals, landing-zone diagrams, network topology diagrams, workload flow diagrams, migration diagrams, or other Azure service relationship diagrams as bitmap images.
---

# Azure Architecture Imagegen

## Overview

Use this skill to turn an Azure architecture brief into an `imagegen` prompt for a clean Microsoft Learn-style diagram. Prefer this skill for conceptual or presentation-ready raster diagrams. If the user needs exact editable geometry, icon fidelity, or selectable text, suggest a follow-up SVG/Visio/PowerPoint implementation after the image draft.

Always save the generated raster image to the workspace so the user can open it later. Use PNG as the default saved format unless the image tool returns a different concrete file type.

## Baseline

The baseline corpus is in `assets/baseline-images/`. It contains four retained Microsoft Visio SVG exports: one Azure Data Factory landing-zone network baseline, two VM landing-zone views for network topology and monitoring, and one simpler VM baseline network view.

Before generating a diagram, read `references/baseline-style.md` when style fidelity matters or when the user asks for a Microsoft Learn, Azure Architecture Center, Visio, official, or baseline-inspired look.

## Workflow

1. Extract the architecture brief:
   - workload or scenario
   - Azure services and external systems
   - trust, subscription, resource group, VNet, subnet, region, or landing-zone boundaries
   - main data/control flows
   - target shape: conceptual, reference architecture, network topology, migration, disaster recovery, or monitoring view

2. Choose the diagram mode:
   - **Conceptual**: few actors around one central service or cloud.
   - **Reference architecture**: grouped Azure resources with directional flows.
   - **Network topology**: VNets, subnets, gateways, firewalls, peering, routes, ingress, egress.
   - **Landing zone**: management, identity, connectivity, workload, monitoring, and governance bands.
   - **Migration/DR**: source side, destination side, replication or cutover arrows, optional numbered phases.

3. Compose the imagegen prompt:
   - Ask for a white canvas, flat Azure architecture diagram, Microsoft Learn documentation style.
   - Use official-looking Azure service icon shapes, but do not require perfect logos.
   - Keep labels short and readable; avoid paragraphs and tiny text.
   - Use dashed containers for Azure, subscriptions, resource groups, VNets, subnets, zones, and on-premises boundaries.
   - Use black or gray arrows for primary flows; use blue or green dashed arrows only when distinguishing network paths, monitoring, failover, or replication.
   - Include a compact legend only if it materially improves comprehension.

4. Generate with `imagegen` using the final prompt. Do not summarize instead of generating when the user explicitly wants an image.

5. Save the generated image under `outputs/azure-architecture-imagegen/` in the current workspace. Create the folder if needed. Use a lowercase slug from the scenario plus a timestamp, for example `outputs/azure-architecture-imagegen/private-aks-landing-zone-20260702-1430.png`.
   - Prefer `.png` because imagegen outputs raster images and PNG is the default handoff format for diagrams.
   - If the tool returns a file in another raster format, preserve that extension instead of renaming blindly.
   - Return the saved file path in the final response.

6. After generation, sanity-check the result:
   - Service names should be plausible and not hallucinated beyond the brief.
   - Flow direction should match the requested architecture.
   - Labels should not be crowded or central to correctness if imagegen text is imperfect.
   - Boundary boxes should make ownership and network scope clear.

## Prompt Skeleton

```text
Create a clean Microsoft Learn-style Azure architecture diagram on a white canvas.
Scenario: <scenario>.
Diagram mode: <conceptual/reference architecture/network topology/landing zone/migration/DR>.
Use these groups: <boundaries>.
Use these Azure services and external systems: <services>.
Show these flows: <numbered or named flows>.
Visual style: flat vector-like documentation diagram, Segoe UI-like labels, crisp Azure-blue accents,
dashed boundary boxes, simple service icons, black/gray directional arrows, generous whitespace.
Keep text short and readable. Avoid decorative gradients, photorealism, 3D, dark theme, and marketing art.
```

## Text Fidelity

Imagegen can struggle with small labels. For dense architectures, use numbered green or blue callouts on the diagram and keep service labels short. If exact text is required, generate a clean unlabeled or lightly labeled image first, then offer to recreate the final diagram in an editable format.
