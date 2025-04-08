# Upload all packages in a folder to a package manager source

## Introduction

When migrating package manager, it sometimes can become necessary to download all packages from a custom repository. A typical use case is with git builders where a typical migration path would be to first download all packages in the repo, then reupload to the new package manager and finally configure the git builders on the new server. This script can be used to facilitate the reupload. 

## How to use

In `upload.R`, simply change 

* `pm_url` - the base URL of your current package manager 
* `source_name` - name of the package manager source
* `src_dir` - the name of the folder where all your packages are stored
* `ppm_token` - a token from package manager with at least the `sources:write` scope

Once you then run `upload.R`, ALL packages (including archived versions) will be uploaded from the folder `src_dir` to the package manager `pm_url` and its source `source_name`.

### creation of token

You can log into the package manager via ssh and execute 

```{bash}
rspm create token --description="Upload packages" \
                  --sources=source_name --expires=30d --scope=sources:write 
```

where `source_name` you will need to replace with the actual name of your target source.

