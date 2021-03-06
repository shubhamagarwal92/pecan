#-------------------------------------------------------------------------------
# Copyright (c) 2012 University of Illinois, NCSA.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the 
# University of Illinois/NCSA Open Source License
# which accompanies this distribution, and is available at
# http://opensource.ncsa.illinois.edu/license.html
#-------------------------------------------------------------------------------

## -------------------------------------------------------------------------------------------------#
##' Convert MAESPA output into the NACP Intercomparison format (ALMA using netCDF)
##' 
##' @name model2netcdf.MAESPA
##' @title Code to convert MAESPA's output into netCDF format
##'
##' @param outdir Location of MAESPA output
##' @param sitelat Latitude of the site
##' @param sitelon Longitude of the site
##' @param start_date Start time of the simulation
##' @param end_date End time of the simulation
##' @param stem_density Number of trees/plotsize. Values in trees.dat
##' @export
##'
##' @author Tony Gardella
##' @importFrom ncdf4 ncvar_def
model2netcdf.MAESPA <- function(outdir, sitelat, sitelon, start_date, end_date, stem_density) {
  
  library(Maeswrap)
  
  ### Read in model output using Maeswrap. Dayflx.dat, watbalday.dat
  dayflx.dataframe    <- readdayflux(filename = "Dayflx.dat")
  watbalday.dataframe <- readwatbal(filename = "watbalday.dat")
  
  # moles of Carbon to kilograms
  mole2kg_C <- 0.0120107
  # Seconds in a day
  secINday <- 60 * 60 * 24
  
  ### Determine number of years and output timestep
  start_date <- as.POSIXlt(start_date, tz = "GMT")
  end_date <- as.POSIXlt(end_date, tz = "GMT")
  start_year <- lubridate::year(start_date)
  end_year <- lubridate::year(end_date)
  years <- start_year:end_year
  
  for (y in years) {
    if (file.exists(file.path(outdir, paste(y, "nc", sep = ".")))) {
      next
    }
    print(paste("---- Processing year: ", y))  # turn on for debugging
    
    ## Set up outputs for netCDF file in appropriate units
    output <- list()
    output[[1]] <- (dayflx.dataframe$totPs) * mole2kg_C * stem_density  # (GPP) gross photosynthesis. mol tree-1 d-1 -> kg C m-2 s-1
    output[[2]] <- (dayflx.dataframe$netPs) * mole2kg_C * stem_density  # (NPP) photosynthesis net of foliar resp mol tree-1 d-1 -> kg C m-2 s-1
    output[[3]] <- (watbalday.dataframe$et)/secINday  # (Tveg) modeled canopy transpiration   mm -> kg m-2 s-1
    output[[4]] <- (watbalday.dataframe$qh) * 1e+06  # (Qh) Sensible heat flux MJ m-2 day-1 -> W m-2
    output[[5]] <- (watbalday.dataframe$qe) * 1e+06  # (Qle)latent Heat flux MJ m-2 day-1 -> W m-2
    
    # ******************** Declare netCDF variables ********************#
    t <- ncdim_def(name = "time", 
                   units = paste0("days since ", y, "-01-01 00:00:00"), 
                   vals = (dayflx.dataframe$DOY), 
                   calendar = "standard", 
                   unlim = TRUE)
    lat <- ncdim_def("lat", "degrees_north", vals = as.numeric(sitelat), longname = "station_latitude")
    lon <- ncdim_def("lon", "degrees_east", vals = as.numeric(sitelon), longname = "station_longitude")
    
    for (i in seq_along(output)) {
      if (length(output[[i]]) == 0) 
        output[[i]] <- rep(-999, length(t$vals))
    }
    
    mstmipvar <- PEcAn.utils::mstmipvar
    var      <- list()
    var[[1]] <- ncvar_def("GPP", units = ("kg C m-2 s-1"), dim = list(lat, lon, t), missval = -999, 
                          longname = "Gross Primary Production")
    var[[2]] <- ncvar_def("NPP", units = ("kg C m-2 s-1"), dim = list(lat, lon, t), missval = -999, 
                          longname = " Net Primary Production")
    var[[3]] <- ncvar_def("TVeg", units = ("kg m-2 s-1"), dim = list(lat, lon, t), missval = -999, 
                          longname = "EvapoTranpiration")
    var[[4]] <- ncvar_def("Qh", units = ("W m-2"), dim = list(lat, lon, t), missval = -999, longname = "Sensible Heat Flux")
    var[[5]] <- ncvar_def("Qle", units = ("W m-2"), dim = list(lat, lon, t), missval = -999, longname = "latent Heat Flux")
    
    ### Output netCDF data
    nc <- ncdf4::nc_create(file.path(outdir, paste(y, "nc", sep = ".")), var)
    varfile <- file(file.path(outdir, paste(y, "nc", "var", sep = ".")), "w")
    for (i in seq_along(var)) {
      # print(i)
      ncdf4::ncvar_put(nc, var[[i]], output[[i]])
      cat(paste(var[[i]]$name, var[[i]]$longname), file = varfile, sep = "\n")
    }
    close(varfile)
    ncdf4::nc_close(nc)
  }  ### End of year loop
  
}  ### End of function  
