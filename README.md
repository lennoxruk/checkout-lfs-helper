# Checkout LFS Helper Action

![version](./version.svg)

When retrieving LFS files within a Gitea Actions workflow, the action _actions/checkout_ does not work correctly with lfs set to true.

For example, the following actions step, will retrieve binary files but the contents will not be downloaded correctly.

```yaml
- name: Check out repository code
  uses: actions/checkout@v4
  with:
    lfs: true
    fetch-depth: 0
```

This Gitea Action is a hack for retrieving LFS files in a Gitea workflow. It is just a simple workaround for the problem, see [background](#background) for explanation.

## How to use

Use in workflow as below, just invoke the checkout-lfs-hack action after the checkout step.

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

Ensure git-lfs is available in workflow; it can be added by including the following step before invoking the action if necessary.

```yaml
- name: Install dependencies
  run: |
    apt update
    apt install git-lfs
```

## Background

The Github action _actions/checkout_ does not retrieve complete binaries from LFS enabled Gitea repositories when used in a Gitea action workflow. Hopefully Gitea actions will be fixed in future but for now there is a hack.

This workaround is modified from [https://gitea.com/gitea/act_runner/issues/164](https://gitea.com/gitea/act_runner/issues/164) which fixed the problem in my Gitea workflows with one small change. The change is just to use the _gitea.ref_ variable instead of the proposed _gitea.ref_name_ as I found this variable always contained the correct branch reference path in my use case and the code given did not work and this made it simpler.

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
      readonly replaceStr="EscapeForwardSlash ${{ gitea.repository }}.git/info/lfs/objects/batch"; sed -i "s/\(\[http\)\( \".*\)\"\]/\1\2`$replaceStr`\"]/" .git/config
      git lfs install --local
      git config --local lfs.transfer.maxretries 1
      git lfs fetch origin ${{ gitea.ref }}
      git lfs checkout
```

This code can be used in any workflow when repository contains LFS files.

The action just executes these same steps and provides a convenient way to be used in different workflows.
