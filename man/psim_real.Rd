% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/psim_real.R
\name{psim_real}
\alias{psim_real}
\title{Stpp from real (sample) origins}
\usage{
psim_real(n_events, ppt, start_date = NULL, poly = NULL,
s_threshold = NULL, step_length = 20, n_origin=50,
restriction_feat=NULL, field=NA,
p_ratio=20, interactive = FALSE, crsys = NULL)
}
\arguments{
\item{n_events}{number of points
(events) to simulate. Default: \code{1000}.
A vector of integer values can be supplied, such as,
c(\code{a}1, \code{a}2, ....)\verb{, where }a\verb{1, }a`2, ...
represent different integer values.}

\item{ppt}{A 3-column matrix or list containing
\code{x} - eastings, \code{y} - northing, and \code{t} - time of occurrence
(in the format: `yyyy-mm-dd').}

\item{start_date}{the start date of the temporal pattern.
The date should be in the format \code{"yyyy-mm-dd"}.
The temporal pattern will normally cover
1-year period.}

\item{poly}{(An sf or S4 object)
a polygon shapefile defining the extent of the landscape}

\item{s_threshold}{defines the spatial
perception range of a walker at a given
location. Default: \code{250} (in the same
linear unit
as the \code{poly} - polygon shapefile).}

\item{step_length}{the maximum step taken
by a walker from one point to the next.}

\item{n_origin}{number of locations to serve as
origins for walkers. Default:\code{50}.}

\item{restriction_feat}{(An S4 object) optional
shapefile containing features
in which walkers cannot walk through.
Default: \code{NULL}.}

\item{field}{a number in the range of \code{[0-1]}
(i.e. restriction values) assigned
to all features; or
the name of a numeric field to extract such
restriction values for different classes of
feature.
Restriction value \code{0} and \code{1} indicate the
lowest and the highest obstructions, respectively.
Default: \code{NULL}.}

\item{p_ratio}{the smaller of the
two terms of proportional ratios.
For example, a value of \code{20}
implies \code{20:80} proportional ratios.}

\item{interactive}{Whether to run the process in
interactive mode. Default is \code{FALSE}. If \code{TRUE},
a user is able to preview the spatial and temporal models
of the expected distribution of the final simulated
events (points).}

\item{crsys}{(string) the EPSG code of the projection
system of the \code{ppt} coordinates. This only used if
\code{poly} argument is \code{NULL}.
See "http://spatialreference.org/" for the list of
EPSG codes for different regions of the world.
As an example, the EPSG code for the British National Grid
projection system is: \code{"EPSG:27700"}.}
}
\value{
Returns a list of artificial spatiotemporal
point patterns generated based on a sample
real data.
}
\description{
Generates spatiotemporal point pattern
from origins sampled based on real sample dataset.
}
\details{
The movement characteristics of walkers as well
as the configuration of the landscape are defined
based on the properties learnt from the real sample
data. See under \code{psim_artif}
function for details on the computation time and
the exported objects.
}
\examples{
\dontrun{
data(camden_crimes)
#subset 'theft' crime
theft <- camden_crimes[which(camden_crimes$type ==
"Theft"),]

#specify the proportion of full data to use
sample_size <- 0.2
set.seed(1000)
dat_sample <- theft[sample(1:nrow(theft),
round((sample_size * nrow(theft)), digits=0),
replace=FALSE),1:3]
#plot(dat_sample$x, dat_sample$y) #preview

#load boundary and land use of Camden
load(file = system.file("extdata", "camden.rda",
package="stppSim"))
landuse = camden$landuse # get landuse

#simulate data
simulated_stpp <- psim_real(n_events=2000, ppt=dat_sample,
start_date = NULL, poly = NULL, s_threshold = NULL,
step_length = 20, n_origin=20,
restriction_feat = NULL, field=NULL,
p_ratio=20, interactive = FALSE, crsys = "EPSG:27700")

#If `n_events` is a vector of values,
#retrieve the simulated data for the
#corresponding vector element by using
#`simulated_stpp[[enter-element-index-here]]`, e.g.,
#to retrieve the first dataframe, use
#simulated_stpp[[1]].

#The above example simulates point patterns on
#an unrestricted landscape. If
#`restriction_feat = landuse` and
#`field = "restrVal"`, then the simulation
#is run with the landuse features as restrictions
#on the landscape.
}

}
\references{
Davies, T.M. and Hazelton, M.L. (2010), Adaptive
kernel estimation of spatial relative risk,
Statistics in Medicine, 29(23) 2423-2437.
Terrell, G.R. (1990), The maximal smoothing principle
in density estimation, Journal of the
American Statistical Association, 85, 470-477.
}
