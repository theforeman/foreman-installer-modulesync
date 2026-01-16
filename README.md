# ModuleSync Configs

This repository contains default configuration for
[modulesync](https://github.com/puppetlabs/modulesync) for the Foreman
puppet modules. Changes to this repository should be synced with modulesync
across all of the Foreman installer modules.

A full description of ModuleSync can be found in [ModuleSync's
README](https://github.com/puppetlabs/modulesync).

## Bulk updating of module dependencies

You can use [metadata_json_deps](https://github.com/ekohl/metadata_json_deps) to verify all modules allow the latest (released) modules on the [Forge](https://forge.puppet.com/). See its README for details, but it boils down to:

```console
$ bundle exec rake metadata_deps
...
$ bundle exec bump-dependency-upper-bound puppetlabs/stdlib 8.0.0 modules/*/*/metadata.json
...
```

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

### Stable releases

All the release scripts assume they're releasing to master. For a stable release, additional parameters are needed. All of the above scripts accept parameters. The first is the directory where to execute.

To create a release PR for the current directory to the 11.1-stable branch, first get your working directory set up correctly. This means that git should point to the correct code and `CHANGELOG.md` is prepared. Bundler should also have all gems installs. In the regular workflow, the `changelogs` command does this, but [Github Changelog Generator](https://github.com/github-changelog-generator/github-changelog-generator) doesn't really support non-linear releases (with branches) so in practice it's easier to do so by hand.

Once all the code is prepared, a PR should be submitted:

```console
$ ../../bin/release-pr . 11.1-stable
```

Once approved, merging also accepts the same arguments:

```console
$ ../../bin/release-merge . 11.1-stable
```

`release-module` performs no git operations and behaves the same regardless of stable/master. `release-merge` already calls it so it's not documented here.

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
