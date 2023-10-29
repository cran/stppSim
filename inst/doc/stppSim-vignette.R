## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----functions, include=FALSE-------------------------------------------------
# A function for captioning and referencing images
fig <- local({
    i <- 0
    ref <- list()
    list(
        cap=function(refName, text) {
            i <<- i + 1
            ref[[refName]] <<- i
            paste("Figure ", i, ": ", text, sep="")
        },
        ref=function(refName) {
            ref[[refName]]
        })
})

## ----figs1, warnings=FALSE, echo=FALSE, out.width="90%", out.height="100%", fig.align = "center", fig.cap=fig$cap("figs1","Type of origin concentration")----
knitr::include_graphics("origins.png")

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  #load shapefile data
#  load(file = system.file("extdata", "camden.rda", package="stppSim"))
#  #extract boundary shapefile
#  boundary = camden$boundary # get boundary
#  #compute the restriction map
#  restrct_map <- space_restriction(shp = boundary,res = 20, binary = TRUE)
#  #plot the restriction map
#  plot(restrct_map)

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # get landuse data
#  landuse = camden$landuse
#  
#  #compute the restriction map
#  full_restrct_map <- space_restriction(shp = landuse,
#       baseMap = restrct_map, res = 20, field = "restrVal", background = 1)
#  
#  #plot the restriction map
#  plot(full_restrct_map)

## ----figs2, echo=FALSE, out.width="100%", out.height="100%", fig.align = "center", fig.cap=fig$cap("figs2","Restriction map")----
knitr::include_graphics("restrictionMap.png")

## ----figs3, echo=FALSE, out.width="70%", out.height="50%", fig.align = "center", fig.cap=fig$cap("figs3", "Global trends and patterns")----
knitr::include_graphics("trend.png")

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  #To install from  `CRAN`
#  install.packages("stppSim")
#  
#  #To install the `developmental version`, type:
#  remotes::install_github("MAnalytics/stppSim")
#  #Note: `remotes` is an extra package that needed to be installed prior to the running of this code.

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  library(stppSim)

## ----eval=FALSE, echo = TRUE, message=FALSE, warning=FALSE--------------------
#  
#  #load the data
#  load(file = system.file("extdata", "camden.rda",
#                          package="stppSim"))
#  
#  boundary <- camden$boundary # get boundary data
#  
#  #specifying data sizes
#  pt_sizes = c(200, 1000, 2000)
#  
#  #simulate data
#  artif_stpp <- psim_artif(n_events=pt_sizes, start_date = "2021-01-01",
#    poly=boundary, n_origin=50, restriction_feat = NULL,
#    field = NA,
#    n_foci=5, foci_separation = 10, mfocal = NULL,
#    conc_type = "dispersed",
#    p_ratio = 20, s_threshold = 50, step_length = 20,
#    trend = "stable", fpeak=NULL,
#    slope = NULL,show.plot=FALSE, show.data=FALSE)
#  

## ----eval=FALSE---------------------------------------------------------------
#  stpp_1000 <- artif_stpp[[2]]

## ----figs4, echo=FALSE, out.width="100%", out.height="100%", fig.align = "center", fig.cap=fig$cap("figs4", "Simulated spatial point patterns of Camden")----
knitr::include_graphics("fromscratch.png")

## ----figs5, echo=FALSE, out.width="100%", out.height="100%", fig.align = "center", fig.cap=fig$cap("figs5","Simulated global trends and patterns (gtp)")----
knitr::include_graphics("temporalscratch.png")

## ----figs6, echo=FALSE, out.width="50%", out.height="50%", fig.align = "center", fig.cap=fig$cap("figs6", "Gtp with an earlier first seasonal peak")----
knitr::include_graphics("onemonth.png")

## ----eval=FALSE, echo = TRUE, message=FALSE, warning=FALSE--------------------
#  
#  #load the data
#  load(file = system.file("extdata", "camden.rda",
#                          package="stppSim"))
#  
#  boundary <- camden$boundary # get boundary data
#  
#  #specifying data sizes
#  pt_sizes = c(1500)
#  
#  #simulate data
#  artif_stpp <- psim_artif(n_events=pt_sizes, start_date = NULL,
#    poly=boundary, n_origin=50, restriction_feat = NULL,
#    field = NA,
#    n_foci=5, foci_separation = 10, mfocal = NULL,
#    conc_type = "dispersed",
#    p_ratio = 20, s_threshold = 50, step_length = 20,
#    trend = "stable", fpeak=NULL,
#    shortTerm = "acyclical"
#    s_band = c(0, 200),
#    t_band = c(1,2),
#    slope = NULL,show.plot=FALSE, show.data=FALSE)
#  

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  
#  #load Camden crimes
#  data(camden_crimes)
#  
#  #extract 'theft' crime
#  theft <- camden_crimes %>%
#    filter(type == "Theft")
#  
#  #print the total no. of records
#  nrow(theft)

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  
#  #specify the proportion of total records to extract
#  sample_size <- 0.3 #i.e., 30%
#  
#  set.seed(1000)
#  dat_sample <- theft[sample(1:nrow(theft),
#    round((sample_size * nrow(theft)), digits=0),
#    replace=FALSE),1:3]
#  
#  #print the number of records in the sample data
#  nrow(dat_sample)

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  
#  plot(dat_sample$x, dat_sample$y,
#      pch = 16,
#       cex = 1,
#       main = "Sample data at unique locations",
#       xlab = "x",
#       ylab = "y")

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  agg_sample <- dat_sample %>%
#    mutate(y = round(y, digits = 0))%>%
#    mutate(x = round(x, digits = 0))%>%
#    group_by(x, y) %>%
#    summarise(n=n()) %>%
#    mutate(size = as.numeric(if_else((n >= 1 & n <= 2), paste("1"),
#                          if_else((n>=3 & n <=5), paste("2"), paste("2.5")))))
#  
#  dev.new()
#  itvl <- c(1, 2, 2.5)
#  plot(agg_sample$x, agg_sample$y,
#       pch = 16,
#       cex=findInterval(agg_sample$size, itvl),
#       main = "Sample data aggregated at unique location",
#       xlab = "x",
#       ylab = "y")
#  legend("topright", legend=c("1-2","3-5", ">5"), pt.cex=itvl, pch=16)
#  
#  #hist(agg_sample$size)

## ----figs7, echo=FALSE, out.width="100%", out.height="100%", fig.align = "center", fig.cap=fig$cap("figs7", "Sample real data (a) unaggregated and (b) aggregated by locations")----
knitr::include_graphics("samplerealvssampleaggregated.png")

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  
#  #As the actual size of any real (full) dataset
#  #would not be known, therefore we will assume
#  #`n_events` to be `2000`. In practice, a user can
#  #infer `n_events` from several other sources, such
#  #as other available full data sets, or population data,
#  #etc.
#  
#  #Simulate
#  sim_fullData <- psim_real(n_events=2000, ppt=dat_sample,
#    start_date = NULL, poly = NULL, s_threshold = NULL,
#    step_length = 20, n_origin=50, restriction_feat=landuse,
#    field="restrVal", p_ratio=20, crsys = "EPSG:27700")
#  

## ----eval=FALSE, echo=FALSE, warning=FALSE------------------------------------
#  #read
#  load(file="C:/Users/monsu/Documents/GitHub/stppSim backup/simulation_for_vignette/sim_fullData.rda")
#  sim_d <- sim_fullData[[1]]
#  

## ----eval=FALSE, echo=TRUE, warning=FALSE-------------------------------------
#  summary(sim_fullData[[1]])

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  
#  #get the restriction data
#  landuse <- as_Spatial(landuse)
#  
#  simulated_stpp_ <- psim_real(
#    n_events=2000,
#    ppt=dat_sample,
#    start_date = NULL,
#    poly = NULL,
#    netw = NULL,
#    s_threshold = NULL,
#    step_length = 20,
#    n_origin=100,
#    restriction_feat = landuse,
#    field="restrVal",
#    p_ratio=20,
#    interactive = FALSE,
#    s_range = 600,
#    s_interaction = "medium",
#    crsys = "EPSG:27700"
#  )
#  

## ----eval=FALSE, message=FALSE, warning=FALSE---------------------------------
#  
#  #extract the output of a simulation
#  stpp <- simulated_stpp_[[1]]
#  
#  stpp <- stpp %>%
#    dplyr::mutate(date = substr(datetime, 1, 10))%>%
#    dplyr::mutate(date = as.Date(date))
#  
#  #define spatial and temporal thresholds
#  s_range <- 600
#  s_thres <- seq(0, s_range, len=4)
#  
#  t_thres <- 1:31
#  
#  #detect space-time interactions
#  myoutput2 <- NRepeat(x = stpp$x, y = stpp$y, time = stpp$date,
#                          sds = s_thres,
#                          tds = t_thres,
#                          s_include.lowest = FALSE, s_right = FALSE,
#                          t_include.lowest = FALSE, t_right = FALSE)
#  
#  #extract the knox ratio
#  knox_ratio <- round(myoutput2$knox_ratio, digits = 2)
#  
#  #extract the corresponding significance values
#  pvalues <- myoutput2$pvalues
#  
#  #append asterisks to significant results
#  for(i in 1:nrow(pvalues)){ #i<-1
#      id <- which(pvalues[i,] <= 0.05)
#      knox_ratio[i,id] <- paste0(knox_ratio[i,id], "*")
#  
#  }
#  
#  #output the results
#  knox_ratio
#  

## ----figs8, echo=FALSE, out.width="100%", out.height="100%", fig.align = "center", fig.cap=fig$cap("figs8", "Setting an earlier first seasonal peak")----
knitr::include_graphics("simvsreal_spatial.png")

## ----figs9, echo=FALSE, out.width="100%", out.height="100%", fig.align = "center", fig.cap=fig$cap("figs9", "Global temporal pattern of (a) simulated and (b) full real data set ")----
knitr::include_graphics("simvsreal_temporal.png")

## ----table1, results='asis', echo=FALSE, tidy.opts=list(width.cutoff=50)------
table <- data.frame(cbind(Dimension = c("Spatial", "","","Temporal","",""),
      Scale_sq.mts = c(150, 250, 400, "Daily", "Weekly", "Monthly"),
      Corr.Coeff = c(.50, .62, .78, .34, .78, .93)))

knitr::kable(table, caption = "Table 1. `Correlation between simulated and real data sets`", row.names=FALSE, align=c("l", "r", "r"))

## ----eval=FALSE, echo=TRUE, warning=FALSE-------------------------------------
#  
#  #load 'area1' object - boundary of Camden, UK
#  load(file = system.file("extdata", "camden.rda",
#                          package="stppSim"))
#  
#  camden_boundary = camden$boundary
#  
#  #load 'area2' - boundary of Birmingham, UK
#  load(file = system.file("extdata", "birmingham_boundary.rda",
#                          package="stppSim"))
#  
#  #run the comparison
#  output <- compare_areas(area1 = camden_boundary,
#                area2 = birmingham_boundary, display_output = FALSE)
#  

## ----eval=FALSE, echo=FALSE, warning=FALSE------------------------------------
#  output$comparison

