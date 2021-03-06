﻿import-module au
import-module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

$exec = "http://download.easeus.com/free/epm_e1125.exe"

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(^\s*url\s*=\s*)('.*')"          = "`$1'$($Latest.URL32)'"
      "(?i)(^\s*checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
      "(?i)(^\s*checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
    }
  }
}

function GetResultInformation([string]$url32) {
  $url32 = Get-RedirectedUrl $url32

  $dest = Join-Path $env:TEMP ($exec -split '/' | select -Last 1)  
  $checksumType = 'sha256'
  Get-WebFile $url32 $dest
  $version = Get-Version (Get-Item $dest | % { $_.VersionInfo.ProductVersion })
  $checksum32 = Get-FileHash $dest -Algorithm $checksumType | % { $_.Hash.ToLowerInvariant() }

  return @{
    URL32          = $url32
    Version        = $version
    Checksum32     = $checksum32
    ChecksumType32 = $checksumType
    PackageName    = 'PartitionMasterFree'
  }
}

function global:au_GetLatest {
  Update-OnETagChanged -execUrl $exec -OnEtagChanged {
    GetResultInformation $exec
  } -OnUpdated { @{ URL32 = $exec } }
}

update -ChecksumFor none
