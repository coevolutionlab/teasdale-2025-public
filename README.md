# Data and Code Access Portal for the dl20 Project

This repository collates links to code and data generated as part of **Teasdale
and Murray *et al.* (2025)**. We are in the process of exporting our
`git-annex` repository in a way that does not leak storage API keys. This
repository is the result, and is still being updated. If you need immediate
access to any specific data which is not listed publicly here, please contact
the lead authors.

# Data

Reads and genomes are available here:
<https://www.ebi.ac.uk/ena/browser/view/PRJEB91362>. This includes some of our
genomes were originally released as part of Wlodimeritz et al. (2023). Beware,
there are discrepancies between our reads and some reassemblies released with
Wlodimeritz et al. (2023).


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
CLI for IGV.js (which powers the above visualisations).

#### `nlrtracker`

We had to use a patched version of Toshiyuki Sakai's  `nlrtracker`, originally
from the [Ref Plant NLR paper (Kourelis et al.
2021)](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3001124).
Our patched version is available at <https://github.com/kdm9/NLRtracker>. This
should be functionally equivalent to the [upstream
version](https://github.com/slt666666/NLRtracker), but works around issues with
concurrent runs and updates to InterProScan.
