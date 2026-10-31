---
name: enrich-user-story
description: Refina una user story vaga en una historia lista para especificar. Detecta ambigüedades, pregunta lo que falta y nunca inventa criterios de aceptación. Usar antes de /opsx:propose.
disable-model-invocation: true
---

# Enriquecer user story

Entrada: la historia tal como la escribió el usuario (en el mensaje o en un ticket).

## Pasos
1. Leé el contexto disponible: `openspec/specs/`, `CLAUDE.md`, y `templates/system-spec.md` o el archivo de spec de sistema del proyecto si existe.
2. Listá las ambigüedades en estas categorías: actores, entradas/salidas, estados, límites y volúmenes, entornos (lab/prod), permisos, qué pasa cuando falla.
3. Hacé como máximo 5 preguntas, de a una, empezando por las que cambian el diseño.
4. Pedí al usuario que escriba o confirme los criterios de aceptación. No los redactes vos: si los inventás, el código y los tests validarán una suposición tuya (validación circular).
5. Devolvé la historia refinada con esta estructura:
   - Objetivo (por qué)
   - Actores
   - Alcance / Fuera de alcance
   - Criterios de aceptación (Dado / Cuando / Entonces), marcados como "confirmados por el usuario"
   - Restricciones (qué no se toca)
   - Riesgos y supuestos
6. Terminá proponiendo el nombre del cambio en kebab-case con prefijo de ticket y el comando: `/opsx:propose <ticket>-<descripcion>`.