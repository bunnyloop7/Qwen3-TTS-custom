$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$originalLocation = Get-Location
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$message) {
    $script:failures.Add($message)
}

try {
    Set-Location $repoRoot

    $requiredPaths = @(
        'AGENTS.md',
        'AI_CONTEXT.md',
        'README.md',
        'VERSION',
        'CHANGELOG.md',
        'docs/ARCHITECTURE.md',
        'docs/DECISIONS.md',
        'docs/NEXT_WORK.md',
        'docs/GOAL_EXECUTION.md',
        'docs/HARNESS_LESSONS.md',
        'docs/IDEA_CANDIDATES.md',
        'scripts/check_harness.ps1',
        'pyproject.toml'
    )

    foreach ($path in $requiredPaths) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            Add-Failure "Missing required path: $path"
        }
    }

    if (Test-Path -LiteralPath 'AGENTS.md' -PathType Leaf) {
        $agents = Get-Content -LiteralPath 'AGENTS.md' -Raw
        $routes = @(
            'AI_CONTEXT.md',
            'docs/ARCHITECTURE.md',
            'docs/DECISIONS.md',
            'docs/NEXT_WORK.md',
            'docs/GOAL_EXECUTION.md',
            'docs/HARNESS_LESSONS.md',
            'CHANGELOG.md',
            'scripts/check_harness.ps1'
        )
        foreach ($route in $routes) {
            if (-not $agents.Contains($route)) {
                Add-Failure "AGENTS.md does not route to: $route"
            }
        }
    }

    $legacyRootDocs = @(
        'ARCHITECTURE.md',
        'DECISIONS.md',
        'NEXT_WORK.md',
        'GOAL_EXECUTION.md',
        'HARNESS_LESSONS.md'
    )
    foreach ($legacy in $legacyRootDocs) {
        if (Test-Path -LiteralPath $legacy -PathType Leaf) {
            Add-Failure "Legacy root document conflicts with canonical path: $legacy"
        }
    }

    if (Test-Path -LiteralPath 'docs/GOAL_EXECUTION.md' -PathType Leaf) {
        $goal = Get-Content -LiteralPath 'docs/GOAL_EXECUTION.md' -Raw
        if ($goal -match '(?i)\b[0-9a-f]{40}\b') {
            Add-Failure 'GOAL_EXECUTION.md must not depend on a commit SHA.'
        }
        if ($goal -match '(?i)\bwork/[A-Za-z0-9._/-]+') {
            Add-Failure 'GOAL_EXECUTION.md must not depend on a work branch.'
        }
        if ($goal -match '(?i)WorkUnit\s*#?\s*\d+') {
            Add-Failure 'GOAL_EXECUTION.md must not depend on a numbered WorkUnit.'
        }
    }

    if ((Test-Path -LiteralPath 'VERSION' -PathType Leaf) -and (Test-Path -LiteralPath 'pyproject.toml' -PathType Leaf)) {
        $version = (Get-Content -LiteralPath 'VERSION' -Raw).Trim()
        $pyproject = Get-Content -LiteralPath 'pyproject.toml' -Raw
        $match = [regex]::Match($pyproject, '(?m)^version\s*=\s*"([^"]+)"\s*$')
        if (-not $match.Success) {
            Add-Failure 'Could not find [project] version in pyproject.toml.'
        } elseif ($version -ne $match.Groups[1].Value) {
            Add-Failure "VERSION mismatch: VERSION=$version pyproject=$($match.Groups[1].Value)"
        }
    }

    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitCommand) {
        Add-Failure 'git is required for tracked-asset safety checks.'
    } else {
        $tracked = @(& git ls-files)
        if ($LASTEXITCODE -ne 0) {
            Add-Failure 'git ls-files failed.'
        } else {
            $forbiddenPatterns = @(
                '(?i)(^|/)\.venv(/|$)',
                '(?i)(^|/)\.env(?!\.example$)($|\.)',
                '(?i)\.(pem|key|p12|pfx)$',
                '(?i)\.(wav|flac|mp3|m4a|safetensors|ckpt|pth|pt)$',
                '(?i)(^|/)voice_clone_prompt_.*\.pt$'
            )
            foreach ($path in $tracked) {
                foreach ($pattern in $forbiddenPatterns) {
                    if ($path -match $pattern) {
                        Add-Failure "Forbidden private/local/model/audio artifact is tracked: $path"
                        break
                    }
                }
            }
        }
    }

    if ($failures.Count -gt 0) {
        Write-Host '[FAIL] Harness checks failed:'
        foreach ($failure in $failures) {
            Write-Host " - $failure"
        }
        exit 1
    }

    Write-Host '[OK] Harness structure and safety checks passed.'
    exit 0
}
finally {
    Set-Location $originalLocation
}
