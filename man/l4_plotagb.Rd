% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/l4_plotagb.R
\name{l4_plotagb}
\alias{l4_plotagb}
\title{Plot AGBD data from GEDI level 4A}
\usage{
l4_plotagb(
  gediL4,
  beam_id = "BEAM0000",
  tct = NULL,
  type = c("location", "distribution", "both"),
  ...
)
}
\arguments{
\item{gediL4}{\code{data.table} or \code{sf_object}: obtained with the function
\code{l4_getmulti}.}

\item{beam_id}{Character: one of "BEAM0000" "BEAM0001" "BEAM0010" "BEAM0011"
"BEAM0101" "BEAM0110" "BEAM1000" "BEAM1011" or "all".}

\item{tct}{Numeric: tree cover threshold from 0 to 100 (in \%).}

\item{type}{Character: one of "location","distribution" or "both". The type
of plot returned. If missing it will be set to "both".}

\item{...}{Others argument to pass to \code{\link[MASS]{MASS::kde2d}} inside
the function \code{get_density}. Only used if \code{type="distribution" or "both"}.
Usually these arguments are: \code{n,h}.}
}
\value{
Returns a ggplot object. See \link[ggplot2:ggplot]{ggplot2::ggplot}
package.
}
\description{
The function plot the location of GEDI footprints and AGBD values against the
elevation. Note that the coordinate reference system must be lon/lat (EPSG
4326).
}
\examples{
data("gedil4")
#plot location of footprints
l4_plotagb(gedil4,type="location")
#plot distribution of agbd based on elevation
l4_plotagb(gedil4,type="distribution")
#change density parameters
l4_plotagb(gedil4,type="distribution",n=200,h=c(200,200))
#plot both types
l4_plotagb(gedil4,type="both",n=200,h=c(200,200))
#plot location of footprint in tree cover >50\%
l4_plotagb(gedil4,type="location",tct=50)
}
\seealso{
\code{\link{l4_plotprofile}}
}
