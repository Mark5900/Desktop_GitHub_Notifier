# Desktop_GitHub_Notifier

Opret en taskbar icon som viser dig antallet af notifikationer i GitHub

## Installation

Du skal installere modulet `PoshTaskbarItem`

```powershell

Install-Module -Name PoshTaskbarItem -Scope CurrentUser

```

Opret en personlig access token med notifications, se guide til oprette en personlig acces token [her](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

Gem din token i følgende fil `$env:userprofile\github_token.txt`.

