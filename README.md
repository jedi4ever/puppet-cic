** Work in progress **

## Description

Puppet Changeset Impact Checker

## Problem:

- Given a puppet tree (with manifest and modules) dir.
- Given a standardized puppet tree with autoloading modules

When rspec-puppet tests and puppet lint tests passes, we need to run against real machines.
Usually this would involve running tests against all roles available.

Instead of re-running test on all possible roles, I want to calculate what roles (classes) were impacted in between revision of the puppet tree, so only need to do a test run on impacted roles.

Roles would translate to classes in puppet tree with a special prefix f.i. role_<bla>

## Usage

Within a CI system - a new build gets params current and previous hash of commits.
If you would run this this tool , you can know on what machines you need to run tests on.
This would be determine the next stage in your current build plan (Bamboo speak)


## Option(1): use standby CI server

Do an actual noop run on CI standby servers and see if things changed using detailed-exit-codes.
This would require us to do a run on CI servers for all possible roles we define in our tree.
And this will take time and will generate a lot of 'unneeded' puppet applies. (debatable)
We want to be clever and detect only the roles that have been impacted by a change.

## Option(2):calculate the impact of the change

1) Get a list of files changed in your puppet tree
F.i. mercurial get a list of files that changed in between revisions. (-S for subrepos)

     hg status --rev cc01cf47d579:3951a60e401e -m -a -r -d   -S

          M moduleA/glbl
               A moduleB/...

 Or git (not sure on submodules) - See <http://stackoverflow.com/questions/1552340/git-show-all-changed-files-between-two-commits>

2) using the filename prefixes we can see what puppet modules have been impacted in between git commits

moduleA, module B are impacted

See - <http://www.devco.net/archives/2012/04/28/trigger-puppet-runs.php>

3) Specify the current state of a node and build a catalog
facts can be given (ala rspec puppet style) or using actual catalog files

See - <https://github.com/ripienaar/puppet-catalog-diff>
See - <https://github.com/rodjek/rspec-puppet/blob/master/lib/rspec-puppet/support.rb>

4) for both commit-ids checkout the puppet tree
either using plain commands or fancy using grit or mercurial-ruby

5) for both commit-ids calculate a list of resources/classes based on given facts
Calculate the dependency tree for a role(class) and see if the roles depend on the module changed.

6) filter the resources based on a role prefix

Et voilà

## Installation
### As a gem

    $ gem install puppet-cic

### From github

    Tested with rvm and ruby-1.8.7

    $ git clone git://github.com/jedi4ever/puppet-cic.git
    $ cd puppet-cic
    $ gem install bundler
    $ bundle install

## Usage

### Using the Gem

    $ puppet-cic

### Using the Github version - through bundler

    $ bundle exec bin/puppet-cic

## Commandline Options

    $ bundle exec bin/puppet-cic help check
    Usage:
      puppet-cic check --factsfile=FACTSFILE

    Options:
      [--repodir=REPODIR]          # Directory where the repository is located
                                   # Default: .
      [--to=TO]                    # Till Revision (defaults last commit)
      [--repotype=REPOTYPE]        # Type of repository (mercurial or git)
                                   # Default: mercurial
      --factsfile=FACTSFILE        # Yaml file that contains facts
      [--from=FROM]                # From revision (defaults last commit -1 )
      [--modulepath=MODULEPATH]    # Path to the puppet modules
                                   # Default: modules
      [--manifestdir=MANIFESTDIR]  # Path to puppet manifests
                                   # Default: manifests
      [--manifest=MANIFEST]        # Path to puppet manifest
                                   # Default: manifests/site.pp

    Given facts specificied by factsfile (Yaml)
    check what puppet modules are impacted by a commit range
