---
name: spec-bridge
description: Conecta el flujo de Superpowers (brainstorming, planes, cierre de rama) con OpenSpec cuando el repo tiene carpeta openspec/. Usar al aprobar un diseño, al planificar tareas, cuando aparece algo fuera de la spec y al terminar una rama.
---

# Puente Superpowers ↔ OpenSpec

Aplica solo si existe `openspec/` en la raíz. Si no existe, no hagas nada.

## Al aprobar un diseño (sale de brainstorming)
- El diseño no queda en `docs/`: se convierte en un cambio de OpenSpec con `openspec-propose`.
- Nombre del cambio: `<ticket>-<descripcion-kebab>` (ej. `DR-12-crear-vswitch`).
- Los criterios de aceptación los escribe o confirma el usuario; copialos tal cual en el delta spec.

## Al planificar (writing-plans)
- El plan se construye a partir de `openspec/changes/<cambio>/tasks.md`, no al revés.
- Cada tarea tiene un criterio de éxito de una frase. Si necesita "y" o "además", dividila.
- Tarea = checkbox: `- [ ] 1.1 Descripción`. Sin checkbox, OpenSpec cuenta cero tareas.

## Durante la implementación
- Si aparece un caso que la spec no contempla: frená, corré `openspec-update-change`, y recién después seguí. Aplica aunque sea un cambio de dos líneas.
- Al terminar cada tarea, marcala en `tasks.md`.

## Al cerrar la rama (finishing-a-development-branch)
1. `openspec-verify-change`: resolvé todos los CRITICAL antes de seguir.
2. En terminal: `openspec validate <cambio> --strict`.
3. Después del merge: `openspec-archive-change`. Nunca edites una spec archivada; un cambio sobre algo archivado es un cambio nuevo.