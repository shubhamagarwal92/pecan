% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/merge.met.variable.R
\name{merge.met.variable}
\alias{merge.met.variable}
\title{Merge a new met variable from an external file (e.g. CO2) into existing met files}
\usage{
\method{merge}{met.variable}(in.path, in.prefix, start_date, end_date,
  merge.file, overwrite = FALSE, verbose = FALSE, ...)
}
\arguments{
\item{in.path}{path to original data}

\item{in.prefix}{prefix of original data}

\item{start_date}{}

\item{end_date}{}

\item{merge.file}{path of file to be merged in}

\item{overwrite}{}

\item{verbose}{}

\item{...}{}
}
\description{
Merge a new met variable from an external file (e.g. CO2) into existing met files
}
\details{
Currently modifies the files IN PLACE rather than creating a new copy of the files an a new DB record. 
Currently unit and name checking only implemented for CO2. 
Currently does not yet support merge data that has lat/lon
New variable only has time dimension and thus MIGHT break downstream code....
}
\examples{
in.path    <- "~/paleon/PalEONregional_CF_site_1-24047/"
in.prefix  <- ""
outfolder  <- "~/paleon/metTest/"
merge.file <- "~/paleon/paleon_monthly_co2.nc"
start_date <- "0850-01-01"
end_date   <- "2010-12-31"
overwrite  <- FALSE
verbose    <- TRUE

\\notrun{
merge.met.variable(in.path,in.prefix,start_date,end_date,merge.file,overwrite,verbose)
PEcAn.DALEC::met2model.DALEC(in.path,in.prefix,outfolder,start_date,end_date)
}
}
