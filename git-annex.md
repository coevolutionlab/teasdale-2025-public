# A primer on obtaining data with git annex

[Git annex](https://git-annex.branchable.com) is an extension of the venerable
git version control system, which allows better handling of large data sets
alongside code and other smaller files. We use git-annex to distribute raw
data, as it enables data versioning, ensures data integrity, and plays nicely
with cloud storage.

## Installation and setup

Easiest is via the prebuilt binaries provided on the [git annex installation
page](https://git-annex.branchable.com/install/) on the git-annex website. You
will need at least version `10.2023*`. Contact Kevin Murray with any issues.

Git annex is also available via conda/mamba:

    conda create -n git-annex -c conda-forge -c bioconda git-annex
    conda activate git-annex


## Steps to obtain data

First, clone this repository:

```bash
git clone https://github.com/coevolutionlab/teasdale-2025-public teasdale25
cd teasdale25
```

Then, initialise git annex:

```bash
git config annex.private true
git annex init
git annex sync
```

Now, let's obtain some data of interest. With git-annex, there is no need to
download the whole repository, simply tell git annex which files you actually
need. For example, let's get the genome assembly fastas, which are in
`assemblies/output/`.Check `README.md` for a full description of available data.


```bash
git annex get assemblies/output
```

Git annex will hopefully have downloaded these files via their zenodo URLs.
These files will then appear as immutable, symlinked 'files'. Please note that
with `git-annex`, all files are read only by default. This is to prevent data
loss, and to ensure that all files are exactly what they are supposed to be.

Next, if you wish, run `fsck` ensure the data was downloaded correctly.

```bash
git annex fsck assemblies/output
```

Obviously, you'll need to repeat this with whichever data is of interest, which
will progress in a similar fashion. If you have any issues, please raise an
issue on this github repository or email Kevin Murray.

