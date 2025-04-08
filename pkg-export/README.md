# Export all packages from given PPM repository

## Introduction

When migrating package manager, it sometimes can become necessary to download all packages from a custom repository. A typical use case is with git builders where a typical migration path would be to first download all packages in the repo, then reupload to the new package manager and finally configure the git builders on the new server. This script can be used to facilitate the download.

## How to use

In `export.R`, simply change 

* `pm_url` - the base URL of your current package manager 
* `repo_name` - name of the repo to be migrated
* `dest_dir` - destination directory for packages 

Once you then run `export.R`, ALL packages (including archived versions) will be downloaded into a directory `dest_dir`.