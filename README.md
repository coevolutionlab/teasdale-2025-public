# Data and Code Access Portal for the dl20 Project

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15828128.svg)](https://doi.org/10.5281/zenodo.15828128)

This page collates links to code and data generated as part of **Teasdale *et
al.* (2025)** Cell Host & Microbe. Because of the volume of data, this
repository primarily contains final outputs rather than intermediates, and we
may have missed files useful to some. If you need immediate access to any
specific data which is not listed publicly here, please contact the lead
authors.

# Data

Reads and genomes are available here:
<https://www.ebi.ac.uk/ena/browser/view/PRJEB91362>. This includes some of our
genomes were originally released as part of Wlodzimierz et al. (2023). Beware,
there are discrepancies between our reads and some reassemblies released with
Wlodzimierz et al. (2023).


# Code

Detailed analysis code is contained in this repository, however is highly
specific, unsupported, often undocumented, and unlikely to be of use in your
own study. Several reusable tools created during this study have been released
separately, and authors wishing to recreate certain analyses from this
manuscript are encouraged to use these tools.


#### `raugraf`

The node radius metric used in the manuscript is implemented as a separate
package, available at <https://github.com/kdm9/raugraf/> and via `pip install
raugraf`.

#### Blindschleiche

<https://github.com/kdm9/blindschleiche>

Many tools within the blindschleiche suite were developed for the dl20 project,
including most GFF file manipulation and sanitisation code, as well as the easy
CLI for IGV.js (which powers our genome viewer).

#### `nlrtracker`

We had to use a patched version of Toshiyuki Sakai's  `nlrtracker`, originally
from the [Ref Plant NLR paper (Kourelis et al.
2021)](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3001124).
Our patched version is available at <https://github.com/kdm9/NLRtracker>. This
should be functionally equivalent to the [upstream
version](https://github.com/slt666666/NLRtracker), but works around issues with
concurrent runs and updates to InterProScan.


# Details

This repository is a [git-annex](https://git-annex.branchable.com) repository.
Find instructions on its use under [git-annex.md](git-annex.md).

We use Zstandard compression in many places. Such files have a `.zst` or
sometimes `.zstd` extension. Zstandard is a modern, high-performance compression
software. Most modern Linux OSs should have it installed already, if not, it is
available with  `apt install zstd`, `conda install zstd`, or from [their
github](https://github.com/facebook/zstd).

