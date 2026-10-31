---
name: powershell-sdd
description: Reglas obligatorias para crear o modificar scripts PowerShell de infraestructura (Hyper-V, clusters, Active Directory, Entra ID). Usar al tocar cualquier archivo .ps1 o .psm1.
---

# PowerShell de infraestructura

## TDD con Pester 5
- Primero el test en `tests/<Nombre>.Tests.ps1`; tiene que fallar antes de implementar.
- Mockeá todo cmdlet que toque infraestructura real: `New-VMSwitch`, `Set-ADUser`, `Connect-MgGraph`, etc.
- Correr: `Invoke-Pester -Path ./tests -Output Detailed`. No declares una tarea terminada sin esa salida.

## Ejecución segura
- Toda función que cambie estado lleva `[CmdletBinding(SupportsShouldProcess)]` y envuelve la acción en `if ($PSCmdlet.ShouldProcess(...))`.
- Desde el agente nunca se ejecuta contra producción: solo `-WhatIf` o un entorno de laboratorio declarado en la spec de sistema.
- Idempotencia: `Get-*` antes de `New-*`; si ya existe, no se recrea.

## Calidad
- `Set-StrictMode -Version Latest` y `$ErrorActionPreference = 'Stop'` al inicio.
- Credenciales solo por `[PSCredential]` o SecretManagement; nunca en texto plano ni en logs.
- `Write-Verbose` en cada acción y un log con fecha en `logs/`.
- Cero advertencias de PSScriptAnalyzer (el hook del plugin lo verifica).