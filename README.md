# Checkout LFS Hack Action

![version](./version.svg)

Gitea Action to workaround git-lfs binary retrieval problem.

When retrieving LFS files within a Gitea Actions workflow, the action _actions/checkout_ does not work correctly with lfs set to true.

```yaml
- name: Check out repository code
  uses: actions/checkout@v4
  with:
    lfs: true
    fetch-depth: 0
```

This will retrieve binary files but the contents will not be correct. This action is just a simple workaround for the problem, see [background](#background) for explanation.

## How to use

Use in workflow as below.

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Audit utils
        run: |
          which git git-lfs
          git version
          git lfs version

      - name: Check out repository code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Checkout LFS
        uses: lennoxruk/checkout-lfs-hack@v1.0
```

## Action reference
<!-- action-docs-inputs -->
<!-- action-docs-inputs -->
<!-- action-docs-outputs -->
<!-- action-docs-outputs -->
<!-- action-docs-runs -->
<!-- action-docs-runs -->

## Background


This does not retrieve complete binaries from LFS. Hopefully it will be fixed in future but for now there is a hack.

Modified the hack from [https://gitea.com/gitea/act_runner/issues/164](https://gitea.com/gitea/act_runner/issues/164) to fix it for my release workflows. The change is just to use the _gitea.ref_ variable instead of the proposed _gitea.ref_name_ as I found it contained the correct reference path in my use case and the code given did not work and this made it simpler.

```yaml
- name: Install utils
   run: |
     apt-get update
     apt-get install -y zip unzip git git-lfs
- name: Check out repository code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0
- name: Checkout LFS
    run: |
      function EscapeForwardSlash() { echo "$1" | sed 's/\//\\\//g'; }
      readonly ReplaceStr="EscapeForwardSlash ${{ gitea.repository }}.git/info/lfs/objects/batch"; sed -i "s/\(\[http\)\( \".*\)\"\]/\1\2`$ReplaceStr`\"]/" .git/config
      git lfs install --local
      git config --local lfs.transfer.maxretries 1
      git lfs fetch origin ${{ gitea.ref }}
      git lfs checkout
```

This code can be inserted into any workflow when repository contains LFS files.

The action just executes these same steps and is more convenient and compact.
