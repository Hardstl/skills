# Baseline Style

Use this reference when creating imagegen prompts for Azure Architecture Center-style diagrams based on the retained baseline images in `../assets/baseline-images/`.

## Package Contents

This experimental skill contains:

- `SKILL.md`: workflow for turning Azure architecture briefs into imagegen prompts.
- `agents/openai.yaml`: UI metadata for the skill.
- `assets/baseline-images/`: four retained Microsoft Visio SVG exports.
- `references/baseline-style.md`: this style reference.

## Baseline Images

The retained image corpus is intentionally small and focused:

- `121-azure-data-factory-baseline-architecture-in-an-azure-landing-zone-03.svg`
  - Visio export name: `azure-data-factory-baseline-network.svg`.
  - Best reference for dense landing-zone network diagrams with readable vector text.
  - Includes on-premises integration, ExpressRoute, connectivity hub, shared services, spoke subscription, private endpoints, RBAC, DNS zones, Azure Policy, Data Factory, Key Vault, Recovery Services vault, Azure Monitor, Log Analytics, Azure Firewall, and Blob Storage.
- `154-azure-virtual-machines-baseline-architecture-in-an-azure-landing-zone-03.svg`
  - Visio export name: `baseline-landing-zone-network-topology.svg`.
  - Best reference for VM landing-zone network topology and hub/spoke boundary composition.
  - The main diagram is embedded as a raster image inside the SVG, so use it as a visual reference rather than a text source.
- `154-azure-virtual-machines-baseline-architecture-in-an-azure-landing-zone-05.svg`
  - Visio export name: `baseline-landing-zone-monitoring.svg`.
  - Best reference for VM landing-zone monitoring, operational, and management views.
  - The main diagram is embedded as a raster image inside the SVG.
- `171-azure-virtual-machines-baseline-architecture-03.svg`
  - Visio export name: `baseline-network.svg`.
  - Best reference for the simpler VM baseline network layout.
  - The main diagram is embedded as a raster image inside the SVG.

Do not assume this package contains the wider Azure Architecture Center scrape. It does not include the earlier SAP, Oracle, AKS, identity, TIC compliance, quarantine, migration, or PDF-processing examples.

## Visual Grammar

- Canvas: white background, landscape by default. Use portrait only for monitoring/operations stacks similar to `154-...-05.svg`.
- Typography: Segoe UI-like sans serif. Labels are black, 10-12 pt equivalent, with bold text reserved for major boundary headings such as `Region`, `Subscription`, `Resource group`, and `Hub virtual network`.
- Containers: use nested rectangles for Azure scope. Common boundaries are on-premises, region, subscription, connectivity hub, shared services, spoke subscription, resource group, VNet, subnet, private endpoint subnet, monitoring, and governance.
- Boundary styling: white or very light gray fills, thin gray/black outlines, and blue dashed rounded rectangles for VNet/subnet-like scopes. The Data Factory baseline also uses pale orange blocks for larger landing-zone areas.
- Azure identity: a Microsoft Azure mark or large Azure boundary label can anchor the diagram, but it should be secondary to the architecture.
- Service icons: use flat Azure portal-style icons with short labels beneath or beside them. Perfect official icon fidelity is less important than recognizable service categories and clean spacing.
- Connectors: use straight or orthogonal arrows. Black arrows indicate primary flows and dependencies; black dashed arrows indicate indirect or cross-boundary paths; gray arrows indicate secondary dependencies; green arrows or dashed green lines highlight selected network/data paths.
- Labels: keep labels short. Prefer service names and scope names over explanatory paragraphs.
- Density: the Data Factory baseline is dense but still grid-aligned. Keep related resources in rows or columns and avoid crossing arrows through labels.

## Layout Patterns

- **Landing-zone network**: on-premises and users at the left or lower-left; connectivity hub and shared services grouped together; workload spokes to the right or below; governance and monitoring shown as separate resource groups or shared services.
- **Hub-spoke topology**: place the hub VNet near the center, spoke VNets around it, and show peering or routing with dashed connectors. Put ExpressRoute, firewall, gateway subnet, and Azure Firewall subnet inside the hub boundary.
- **Private endpoint view**: put private endpoint subnet resources together and label endpoint instances with short `PE-*` names when useful. Connect private endpoints back to workload services with clean dashed arrows.
- **Monitoring/operations view**: use stacked or vertical grouping when showing monitoring, backup, policy, RBAC, DNS, and operational tooling for a VM landing zone.
- **Baseline network view**: keep the VM workload diagram simpler than the landing-zone diagrams. Show users/on-premises, network boundary, VM/application tier, data tier, monitoring, and security controls without overloading the canvas.

## Avoid

- Photorealistic clouds, people, laptops, or data centers.
- Dark mode unless explicitly requested.
- Decorative gradients, bokeh, glossy 3D icons, shadows, or marketing hero art.
- Long labels, paragraphs, tables, or tiny explanatory text inside the image.
- Overclaiming exact official Microsoft icon fidelity. Say "official-looking" or "Azure portal-style" instead.
- Referencing baseline files that are not in `assets/baseline-images/`.
- Claiming coverage for migration, SAP, Oracle, AKS, identity-only, or TIC compliance styles from this package.
