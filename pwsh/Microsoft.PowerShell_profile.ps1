fastfetch -c examples/20
Invoke-Expression (&starship init powershell)
  $ENV:STARSHIP_CONFIG = "$HOME\my_dotfiles\.config\starship\starship.toml"
  Set-Alias v "vim"
# Check if the alias exists
  $aliasExists = Get-Alias ls | Where-Object {$_.Definition -eq "Get-ChildItem"}
  $aliasExists2 = Get-Alias dir | Where-Object {$_.Definition -eq "Get-ChildItem"}

# Remove the alias if it exists and matches the definition
  if ($aliasExists) {
    Remove-Item alias:ls
  }
if ($aliasExists2) {
  Remove-Item alias:dir
}

function ff([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & fastfetch -c examples/7 $params
}
function gla([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & git log --oneline $params
}
function ls([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & eza --icons --group-directories-first
}
function la([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & eza --icons --group-directories-first -a
}
function dir([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & eza --icons --group-directories-first -l -a -h --git-repos-no-status
}
function vprof([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & vim $PROFILE
}
function restart([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope }
}

function vf([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & vim $(fzf)
}

function arch([Parameter(ValueFromRemainingArguments = $true)]$params) {
  & wsl -d ArchLinux
}
