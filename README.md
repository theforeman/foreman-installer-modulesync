# ModuleSync Configs

This repository contains default configuration for
[modulesync](https://github.com/puppetlabs/modulesync) for the Foreman
puppet modules. Changes to this repository should be synced with modulesync
across all of the Foreman installer modules.

A full description of ModuleSync can be found in [ModuleSync's
README](https://github.com/puppetlabs/modulesync).

## Releasing

### Setup

Ensure Git knows which GPG key to use for signing. You can set the key globally with:

```
git config --global user.signingkey <YOUR_KEYID>
```

### Short Single Release Workflow

Generate a changelog

```console
$ ./bin/changelogs modules/puppet-foreman
Updated /path/to/foreman-installer-modulesync/modules/puppet-foreman/CHANGELOG.md
```

Inspect the changelog, (re)label any PRs and issues if needed. Also decide whether a version bump is needed.

```console
$ cd modules/puppet-foreman
$ bundle exec rake module:bump:minor
Bumping version from 13.0.1 to 13.1.0
```

Regenerate the changelog while leaving any git changes:

```console
$ ../../bin/changelogs --skip-git .
Updated /path/to/foreman-installer-modulesync/modules/puppet-foreman/CHANGELOG.md
```

Now send a PR for the release:

```console
$ ../../bin/release-pr
```

Once it's green and ready to merge, it can be merged. Make sure you're still on the same branch:

```console
$ ../../bin/release-merge
```

If someone already merged it but didn't release it, then it can be released:

```console
$ ../../bin/release-module
```

### Short Bulk Release Workflow

This repository also contains scripts to easy module releases. This short workflow:

```console
$ ./bin/tiers --tier 0 modules/puppet-*/metadata.json | awk '{ print $2 }' | xargs ./bin/changelogs
Updated /path/to/foreman-installer-modulesync/modules/puppet-git/CHANGELOG.md
Updated /path/to/foreman-installer-modulesync/modules/puppet-dhcp/CHANGELOG.md
...
```

Go over every changelog module per the Short Single Release Workflow. Once tier 0 is completed, move on to tier 1 and repeat. If any major version was released in the previous tier, make sure it is accepted in `metadata.json`.

### Finding the order

To find the order in which to release, tiers can be used:

```console
$ ./bin/tiers modules/puppet-*/metadata.json
Tier 0
  katello/certs	modules/puppet-certs
  katello/qpid	modules/puppet-qpid
  theforeman/dhcp	modules/puppet-dhcp
  theforeman/dns	modules/puppet-dns
  theforeman/foreman	modules/puppet-foreman
  theforeman/git	modules/puppet-git
  theforeman/puppet	modules/puppet-puppet
  theforeman/tftp	modules/puppet-tftp
Tier 1
  katello/candlepin	modules/puppet-candlepin
  katello/pulp	modules/puppet-pulp
  theforeman/foreman_proxy	modules/puppet-foreman_proxy
Tier 2
  katello/foreman_proxy_content	modules/puppet-foreman_proxy_content
  katello/katello	modules/puppet-katello
Tier 3
  katello/katello_devel	modules/puppet-katello_devel
```

Modules from tier 0 only depend on Puppet itself and external dependencies (maintained by other organizations). Tier 1 depends on tier 0 and so on.

A single tier can be requested with `--tier TIER`.
