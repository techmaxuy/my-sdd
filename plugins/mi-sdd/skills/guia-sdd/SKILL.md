---
name: guia-sdd
description: Genera una guía paso a paso, con prompts y textos ya redactados, para llevar adelante un proyecto nuevo, una feature nueva en un proyecto existente o la corrección de un bug siguiendo la metodología mi-sdd (enrich, OpenSpec propose, Superpowers, verify, archive). Usar cuando el usuario entrega una de esas tres tareas y pide la guía, el plan, los pasos o los prompts.
---

# Guía SDD: de la tarea al paso a paso

Entrada: una tarea, que es un **proyecto nuevo**, una **feature** en un proyecto existente o un **bug**.
Salida: UN documento con el procedimiento completo. Cada paso trae su prompt listo para copiar, ya rellenado con los datos de la tarea.

## 1. Clasificar y completar datos

- **PROYECTO**: carpeta nueva, sin código ni `openspec/`.
- **FEATURE**: repo existente, comportamiento nuevo.
- **BUG**: repo existente, comportamiento incorrecto que hay que corregir.

Si falta algo imprescindible, hacé **una sola ronda de hasta 3 preguntas juntas** (tipo de tarea, ruta del repo, qué área toca). No preguntes lo que se puede deducir. Valores por defecto: Windows, PowerShell 7, Pester 5, spec de sistema en `openspec/system-spec.md`, sin remoto git, modo de permisos por defecto en Claude Code.

## 2. Variables

Derivalas y mostralas en una tabla al inicio del documento. Usalas rellenadas en todos los prompts.

| Variable | Regla | Ejemplo |
| --- | --- | --- |
| `<repo>` | Ruta del proyecto | `C:\Proyectos\ttt-sdd` |
| `<TICKET>` | El que dio el usuario; si no, uno corto | `TTT-01` |
| `<cambio>` | kebab-case, minúsculas, empieza con el ticket; en bugs, prefijo `fix-` | `ttt-01-juego-consola`, `fix-dr-12-vswitch-duplicado` |
| `<rama>` | `feature/<cambio>` o `fix/<cambio>` | `feature/ttt-01-juego-consola` |
| `<worktree>` | `<repo>\.worktrees\` + la rama con cada barra como subcarpeta | `C:\Proyectos\ttt-sdd\.worktrees\feature\ttt-01-juego-consola` |
| `<historia>` | `docs\historias\<TICKET>.md` | `docs\historias\TTT-01.md` |

La barra de la rama crea una subcarpeta en el worktree. Escribí siempre la ruta con ese nivel extra.

## 3. Reglas que la guía no puede romper

1. **Los criterios de aceptación los escribe el humano.** Nunca los des por definitivos. Si el usuario describió el comportamiento, ponelos como "Borrador para editar: vos decidís". Si no, dejá el bloque con `<<placeholders>>`.
2. **Un solo ejecutor en la implementación**: `subagent-driven-development` de Superpowers. Nunca `/opsx:apply` sobre el mismo cambio.
3. **Nada de código sin spec.** Si aparece algo fuera de la spec: `/opsx:update <cambio>` y recién después código.
4. **Dos aprobaciones humanas marcadas ★**: los criterios al proponer (paso 2) y el merge al cerrar la rama (paso 7).
5. **Solo comandos de la sección 6.** No inventes flags ni nombres de skills. Si el nombre de un comando del programa construido no se conoce todavía, el prompt pide a Claude "dame el comando exacto".
6. **Placeholders `<<así>>` solo** para lo que únicamente el humano sabe. Todo lo demás va rellenado.
7. **Lo que una skill devuelve solo en el chat se pide en disco** con un prompt explícito (por ejemplo la historia refinada).
8. Si el proyecto es PowerShell: el prompt de implementación menciona `powershell-sdd`, y los criterios incluyen el comportamiento con `-WhatIf` cuando hay efectos externos.

## 4. Estructura del procedimiento

Cada paso del documento lleva cinco partes: **Dónde** (chat o terminal), **Herramienta**, **Prompt** (bloque de código), **Qué esperar** y **Control**. Después de cada paso, un commit si Claude no lo hizo.

| Paso | PROYECTO | FEATURE | BUG |
| --- | --- | --- | --- |
| A | Preparar carpeta (terminal) | Verificar repo (terminal) | Verificar repo (terminal) |
| 0 | Spec de sistema (chat) | Leer el contexto existente (chat) | Reproducir y hallar la causa raíz (chat) |
| 1 | Refinar historia | Refinar historia | Refinar como historia de corrección |
| 2 ★ | Diseñar y proponer | Diseñar y proponer | Proponer corrección (MODIFIED) |
| 3 | Validar la spec | Validar la spec | Validar la spec |
| 4 | Worktree y plan | Worktree y plan | Worktree y plan |
| 5 | Implementar con subagentes | Implementar con subagentes | Implementar; primero el test de regresión |
| 6 | Revisar y verificar | Revisar y verificar | Revisar y verificar |
| 7 ★ | Cerrar la rama | Cerrar la rama | Cerrar la rama |
| 8 | Archivar | Archivar | Archivar |

### Paso A · Preparar o verificar (terminal)

PROYECTO:

```powershell
New-Item -ItemType Directory -Force <repo> | Out-Null
Set-Location <repo>
git init -b main
"# <nombre del proyecto>" | Out-File README.md -Encoding utf8
".worktrees/`nlogs/`nresultados/" | Out-File .gitignore -Encoding utf8
git add . ; git commit -m "chore: repo inicial"
openspec init --tools claude
git add . ; git commit -m "chore: openspec init"
claude
```

Control: existen `openspec\specs`, `openspec\changes` y skills `openspec-*` en `.claude\skills`; en el chat, `/` muestra `/opsx:propose`, `/opsx:verify` y `/mi-sdd:enrich-user-story`.

FEATURE o BUG:

```powershell
Set-Location <repo>
git status                  # debe estar limpio
git branch --show-current   # la rama base
Test-Path openspec          # False: correr openspec init --tools claude y commitear
openspec list --specs       # capacidades ya especificadas
openspec list               # cambios abiertos: no mezclar con este
claude
```

### Paso 0 · Contexto (chat)

PROYECTO, spec de sistema:

```text
Creá openspec/system-spec.md siguiendo la estructura del template system-spec de mi-sdd
(Propósito, Stack y versiones, Arquitectura, Entornos, Convenciones, Estrategia de tests,
Seguridad, Decisiones permanentes, Zonas prohibidas) para este proyecto:

- <descripción del producto en una línea>
- Stack: <lenguaje, versiones, módulos, framework de tests>
- Estructura: <carpetas y módulos principales>
- Efectos externos: <qué toca fuera del código: archivos, red, servicios, o "ninguno">
- Entornos: <lab y prod, cómo se accede, qué no puede tocar el agente>
- Zona prohibida: <qué nunca se modifica>

Después creá CLAUDE.md con una línea que diga que la spec de sistema está en
openspec/system-spec.md y que se lea antes de proponer cambios. Hacé commit.
```

Control: leer `system-spec.md` y corregirlo ahora; todo lo demás se apoya en esto.

FEATURE:

```text
/opsx:explore <tema de la feature>

Leé openspec/system-spec.md y openspec/specs/. Decime qué capacidades existentes toca
"<resumen de la feature>", qué módulos del código se verían afectados y qué riesgos ves.
No escribas archivos.
```

Control: la lista de capacidades afectadas coincide con lo que esperabas. Si `openspec/system-spec.md` no existe, usá el prompt de PROYECTO antes.

BUG:

```text
/superpowers:systematic-debugging

Bug: <síntoma observable>.
Comportamiento actual: <qué pasa>.
Comportamiento esperado: <qué debería pasar>.
Cómo reproducirlo: <pasos>.
Encontrá la causa raíz sin modificar código. Mostrame la evidencia, el archivo y la línea responsables.
```

Control: la causa raíz está probada con evidencia y la reproducción es repetible.

### Paso 1 · Refinar la historia (chat) · mi-sdd

PROYECTO y FEATURE:

```text
/mi-sdd:enrich-user-story

Historia: Como <actor> quiero <capacidad> para <beneficio>.
Contexto: <datos relevantes: sistemas involucrados, restricciones conocidas>
```

BUG:

```text
/mi-sdd:enrich-user-story

Bug: <síntoma>. Comportamiento actual: <actual>. Esperado: <esperado>.
Causa raíz hallada: <causa>.
Tratalo como una historia de corrección: el criterio principal es el comportamiento
esperado y debe haber un escenario de regresión.
```

La skill hace hasta 5 preguntas y pide los criterios. **No dejes que los invente.** Respondé con los tuyos usando esta plantilla:

```text
Mis criterios de aceptación:
1. Dado <<situación inicial>>, cuando <<acción>>, entonces <<resultado observable>>.
2. Dado <<situación>>, cuando <<acción inválida>>, entonces <<rechazo y mensaje>>.
3. <<un criterio por cada regla de negocio y cada caso de error>>
N. (solo BUG) Regresión: dado <<condición que disparaba el bug>>, cuando <<acción>>, entonces <<resultado correcto>>.
Fuera de alcance: <<lo que no se hace>>
```

Después, en disco:

```text
Guardá la historia refinada tal cual en <historia> y hacé commit.
```

Control: el archivo existe y los criterios dicen "confirmados por el usuario".

### Paso 2 ★ · Diseñar y proponer (chat) · Superpowers + OpenSpec

PROYECTO y FEATURE:

```text
/superpowers:brainstorming

Quiero diseñar la historia de <historia>. Respetá openspec/system-spec.md.
Cuando apruebe el diseño, en vez de dejarlo solo en docs convertilo en un cambio de
OpenSpec llamado <cambio>, copiando mis criterios de aceptación tal cual como escenarios.
```

BUG:

```text
/opsx:propose <cambio>

Corrección del bug descrito en <historia>. En el spec delta usá MODIFIED para el requisito
afectado, con el texto completo del requisito ya corregido, y agregá el escenario de
regresión con mis criterios confirmados. En tasks.md la primera tarea es el test que
reproduce el bug y falla.
```

Si el brainstorming termina sin proponer: `/opsx:propose <cambio>`.

Control ★: abrir `openspec/changes/<cambio>/` y revisar `proposal.md`, `design.md`, `tasks.md` y `specs/*/spec.md`. Los escenarios tienen que ser tus criterios, no otros. Para corregir: `/opsx:update <cambio>` con lo que cambiar.

### Paso 3 · Validar (terminal)

```powershell
openspec validate <cambio> --strict
openspec show <cambio> --diff
openspec status --change <cambio>
```

Control: sin errores y `tasks.md` con checkboxes `- [ ]`.

### Paso 4 · Aislar y planificar (chat) · Superpowers

```text
/superpowers:using-git-worktrees

Creá un worktree para el cambio <cambio> en .worktrees/, con la rama <rama>.
```

```text
/superpowers:writing-plans

Armá el plan a partir de openspec/changes/<cambio>/tasks.md. Una tarea por comportamiento,
cada una con su test primero, su criterio de éxito en una frase y el comando para verificarla.
```

Control: el plan tiene las mismas tareas que `tasks.md`, en pasos chicos. Si Claude pregunta cómo ejecutarlo, elegir subagentes.

### Paso 5 · Implementar (chat) · Superpowers + mi-sdd

```text
/superpowers:subagent-driven-development

Ejecutá el plan en el worktree. Para cada tarea: test que falle primero, implementación,
<comando de tests> con la salida visible, tildar la tarea en
openspec/changes/<cambio>/tasks.md y commit. Aplicá powershell-sdd. No uses /opsx:apply.
```

Para BUG, agregar: "El test de regresión debe fallar con el código actual y pasar después del arreglo; mostrame las dos salidas."

Qué esperar: un subagente implementador y revisores por tarea; el hook de lint corrige errores de `.ps1` en vivo.
Control: tests en verde, todas las casillas de `tasks.md` tildadas, un commit por tarea.

### Paso 6 · Revisar y verificar (chat)

```text
/superpowers:requesting-code-review

Revisá la rama completa contra openspec/changes/<cambio> y contra openspec/system-spec.md.
```

```text
/opsx:verify <cambio>
```

Control: cero CRITICAL. Si aparece un caso no especificado: primero `/opsx:update <cambio>`, después el código. Probar a mano desde `<worktree>`; si no se conoce el comando de entrada, preguntar en el chat: "¿Cuál es la función pública para <usar la feature> y cómo se invoca? Dame el comando exacto."

### Paso 7 ★ · Cerrar la rama (chat) · Superpowers

```text
/superpowers:verification-before-completion
```

```text
/superpowers:finishing-a-development-branch
```

Sin remoto, elegir merge local a main. Control ★: `git log --oneline --graph --all` muestra la rama integrada.

### Paso 8 · Archivar (chat) · OpenSpec

Ya en main:

```text
/opsx:archive <cambio>
```

Control: el cambio quedó en `openspec/changes/archive/AAAA-MM-DD-<cambio>/` y la spec consolidada en `openspec/specs/`. Commit final: `git add . ; git commit -m "docs: archivar <cambio>"`.

## 5. Secciones finales del documento

**Evidencias** (siempre incluirlas, con las variables rellenadas):

```powershell
git log --oneline --graph --all
git worktree list
git log --stat -- openspec docs
openspec list --specs
Get-ChildItem openspec\changes\archive -Recurse -Filter *.md | Select-Object FullName
```

Más una tabla de archivos a abrir (historia, `system-spec.md`, diseño y plan de Superpowers, `proposal.md`, specs delta, `tasks.md` tildado, spec consolidada). Cerrar con el prompt opcional que arma `EVIDENCIA.md` y la regla "si no hay prueba, escribir sin evidencia".

**Si algo sale distinto** (incluir al menos estas filas):

| Qué pasa | Qué hacer |
| --- | --- |
| No aparece `/mi-sdd:enrich-user-story` | `claude plugin details mi-sdd`; verificar que `skills/` esté en la raíz del plugin y los archivos se llamen `SKILL.md`; subir `version`, push y `claude plugin update mi-sdd@mi-sdd` |
| Enrich escribe criterios por su cuenta | "No redactes criterios, pedímelos" |
| Los escenarios no son tus criterios | `/opsx:update <cambio>` pidiendo reemplazarlos por los de `<historia>` |
| `openspec validate --strict` falla | Falta `#### Scenario:` o un requisito sin SHALL/MUST |
| Aparece `/opsx:apply` en el paso 5 | Frenar: un solo ejecutor |
| Un módulo no se encuentra | Importarlo con la ruta completa del worktree (incluye la subcarpeta de la rama) |
| El nombre de la función no existe | `Get-Command -Module <módulo>`; usar el nombre real |
| El hook de lint no actúa | `pwsh -v` y `Get-Module PSScriptAnalyzer -ListAvailable` |
| Se llena el contexto | `/compact`; el plan y `tasks.md` en disco mantienen el estado |

## 6. Comandos permitidos

Chat, OpenSpec: `/opsx:explore`, `/opsx:propose`, `/opsx:apply` (no usar junto con Superpowers), `/opsx:update`, `/opsx:sync`, `/opsx:archive`, `/opsx:verify`, `/opsx:ff`, `/opsx:new`, `/opsx:continue`.
Chat, Superpowers: `/superpowers:brainstorming`, `using-git-worktrees`, `writing-plans`, `subagent-driven-development`, `executing-plans`, `test-driven-development`, `requesting-code-review`, `receiving-code-review`, `systematic-debugging`, `verification-before-completion`, `finishing-a-development-branch`.
Chat, mi-sdd: `/mi-sdd:enrich-user-story`.
Terminal: `openspec init --tools claude`, `openspec update`, `openspec list [--specs]`, `openspec view`, `openspec status --change <c>`, `openspec show <c> --diff`, `openspec validate <c> --strict`, `openspec archive <c> -y`; `claude plugin list | details | validate | update`; `git` estándar.

## 7. Cómo entregar el documento

- Si tenés herramienta de documentos o artefactos: creá un documento titulado `Guía SDD · <tipo> · <cambio>` con las secciones **Resumen y variables**, **Antes de empezar**, **El procedimiento**, **Evidencias**, **Si algo sale distinto**. Llená una sección por vez.
- Si estás en Claude Code sin esas herramientas: escribí `docs\guias\<TICKET>-<tipo>.md` con la misma estructura y decile la ruta.
- Cerrá con una línea que diga cuál es el primer paso. No resumas la guía.

## 8. Revisión antes de entregar

- Ninguna variable `<...>` sin sustituir, salvo las del humano marcadas `<<...>>`.
- Los criterios de aceptación aparecen como bloque para completar o como borrador marcado.
- Están las dos aprobaciones ★.
- Hay un solo ejecutor en el paso 5.
- Todo comando figura en la sección 6.
- Las rutas del worktree incluyen la subcarpeta de la rama.
