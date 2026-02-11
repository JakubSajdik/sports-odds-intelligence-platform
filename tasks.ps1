param(
  [Parameter(Position = 0)]
  [ValidateSet("ingest", "test", "lint", "format", "all")]
  [string]$Task = "all"
)

$ErrorActionPreference = "Stop"

function Run($cmd) {
  Write-Host ">> $cmd"
  iex $cmd
}

if ($Task -eq "ingest") {
  Run "python -m pipeline.run_ingest --all"
  exit 0
}

if ($Task -eq "test") {
  Run "python -m pytest"
  exit 0
}

if ($Task -eq "lint") {
  Run "python -m ruff check pipeline"
  exit 0
}

if ($Task -eq "format") {
  Run "python -m ruff format pipeline"
  exit 0
}

if ($Task -eq "all") {
  Run "python -m ruff format pipeline"
  Run "python -m ruff check pipeline"
  Run "python -m pytest"
  exit 0
}

