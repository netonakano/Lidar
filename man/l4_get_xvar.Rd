% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/l4_get_xvar.R
\name{l4_get_xvar}
\alias{l4_get_xvar}
\title{Get  xvar information from a list of GEDI Level 4 file path}
\usage{
l4_get_xvar(
  gediL4_path,
  ncore = parallel::detectCores() - 1,
  merge = T,
  source = F
)
}
\arguments{
\item{gediL4_path}{Character path to GEDI level 4A h5 file.}

\item{ncore}{Numeric: numbers of core to be used if the maximum core
available is less than the length of \code{gediL4_path} Default to the
number of cores available minus one.}

\item{merge}{Logical: if TRUE (default) the resulted list will be merged with
\code{rbind}. Ignored if \code{length(gediL4_path)==1}}

\item{source}{Logical: if TRUE and \code{merge=TRUE} add a column with the
source path of each observation.Ignored if \code{length(gediL4_path)==1},
and if \code{merge=FALSE}}
}
\value{
an S4 object of class
\link[=data.table:data.table]{data.table}.
}
\description{
Get GEDI L4 xvar information from h5 file format.These information are
related to the Level 2A predictors used to obtain the AGBD estimates and can
be used to reconstruct L2A metrics used for the estimation and the AGBD
estimates itself. See
\href{https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=2056}{here} for more
documentation on GEDI L4 data. The function use the
\link[snowfall:snowfall]{snowfall} package to get data in parallel. There
could be memory allocation problems for an high number of file path.
}
\details{
Part of columns in the output are also present in the output of
\code{l4_getmulti}. The other columns are described in the chapter
\href{https://daac.ornl.gov/GEDI/guides/GEDI_L4A_AGB_Density_V2_1.html#datacharact}{"data
characteristics" on this page}. Relevant columns are:
\itemize{
\item \emph{rh_index.x}: Vector of the height percentile
associated with the given RH metric in GEDI L2A.
\item \emph{predictor_is.x}: The variable predictor_id provides a mapping
between rh_index and par
\item \emph{par.x}: The vector par contains coefficients of the linear
model used to predict AGBD, where the first element is the intercept and
subsequent elements are slope coefficients
\item \emph{V.x }: Values of scaled and transformed GEDI l2A RH metrics
entered in the selected model to estimate AGBD
}
For more information on these data see the Frequently asked question
\href{https://daac.ornl.gov/GEDI/guides/GEDI_L4A_AGB_Density_V2_1.html#acqmatmethods}{here}.
Note that by default the function will drop all footprint in which agbd<0.
These observations are considered sensor errors.
}
\examples{

}
