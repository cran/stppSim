#' @title Artificial spatial origins
#' @description Simulates spatial locations to serve
#' as origins of walkers. If provided, spaces covered
#' by restriction features are avoided. Final
#' origins are assigned probability values
#' indicating the strengths of the origins.
#' @param poly (An sf or S4 object)
#' a polygon shapefile defining the extent
#' of the landscape
#' @param n_origin number of locations to serve as
#' origins for walkers. Default:\code{50}.
#' @param restriction_feat (An S4 object) optional
#' shapefile containing features
#' in which walkers cannot walk through.
#' Default: \code{NULL}.
#' @param  n_foci number of focal points amongst the origin
#' locations. The origins to serve as focal
#' points are based on random selection. `n_foci` must be
#' smaller than `n_origins`.
#' @param foci_separation a value from `1` to `100`
#' indicating the nearness of focal points to one another.
#' A `0` separation indicates that focal points are in
#' close proximity
#' of one another, while a `100` indicates focal points being
#' evenly distributed across space.
#' @param mfocal the c(x, y) coordinates of a single point,
#' representing a pre-defined `main` focal point (origin)
#' in the area. The default is `NULL` in which a random
#' coordinate is chosen within the `polygon` area.
#' @param conc_type concentration of the rest of the
#' origins (non-focal origins) around the focal ones. The options
#' are `"nucleated"` and `"dispersed"`.
#' @param p_ratio the smaller of the
#' two terms of proportional ratios.
#' For example, a value of \code{20}
#' implies \code{20:80} proportional ratios.
#' @usage artif_spo(poly, n_origin=50, restriction_feat = NULL,
#' n_foci=5, foci_separation = 10, mfocal = NULL,
#' conc_type = "nucleated", p_ratio)
#' @examples
#' #load boundary of Camden
#' load(file = system.file("extdata", "camden.rda",
#' package="stppSim"))
#' boundary = camden$boundary # get boundary
#' landuse <- camden$landuse
#' spo <- artif_spo(poly = boundary, n_origin = 50,
#' restriction_feat = landuse, n_foci=5, foci_separation = 0,
#' mfocal = NULL, conc_type = "dispersed", p_ratio=20)
#' @details
#' The focal origins (`n_foci`) serve as the central locations
#' (such as, city centres). The `foci_separation` indicates
#' the nearness of focal origins from one another.
#' The `conc_type` argument allows a user to specify
#' the type of spatial concentration exhibited by the non-focal
#' origin around the focal ones.
#' If `restriction_feat` is provided, its features help
#' to prevent the occurrence of any events in the areas
#' occupied by the features.
#' @return Returns a list detailing the
#' properties of the generated spatial origins
#' with associated
#' strength (probability) values.
#' @importFrom dplyr if_else mutate filter
#' row_number select bind_cols
#' @importFrom splancs csr
#' @importFrom sp CRS SpatialPoints
#' @importFrom utils flush.console
#' @importFrom grDevices chull
#' @importFrom ggplot2 ggplot geom_point
#' geom_polygon theme_bw
#' @importFrom stats dist kmeans
#' @importFrom raster projection
#' @export

artif_spo <- function(poly, n_origin =  50, restriction_feat = NULL,
                      n_foci=5, foci_separation = 10, mfocal = NULL,
                      conc_type = "nucleated", p_ratio = 20){

  origins <- list()

  #define global variables
  group <- bind_cols <- data_frame <- dist <- kmeans <-
    if_else <- row_number <- category <-
    flush.console <- as <- select <- prob <-
    theme <- theme_bw <-
    theme_light <- element_text <-
    slice <- chull <- x <- y <- ggplot <- geom_point <-
    aes <- geom_polygon <- NULL

  #check that the main focal point
  #falls within the boundary.
  if(!is.null(mfocal)){
     #mfocal <- c(526108, 185899)
     #mfocal <- c(5261080, 1858990)
     mfocal_pt <- st_as_sf(SpatialPoints(cbind(mfocal[1], mfocal[2]),
                              proj4string = raster::projection(poly, FALSE)))
    #do they intersect?
    itx <-  data.frame(st_intersects(mfocal_pt, st_as_sf(poly)))[,2]
    if(length(itx) != 1){
      stop("Terminated! 'mfocal' provided does not fall inside the 'polygon' area!!")
    }
  }

  #check the inputs
  if(n_origin <= 0){
    stop("Number of origin points need to be specified!")
  }

  #check values of focal point and
  #foci separations
  if(n_foci >= n_origin){
    stop("focal point cannot be greater than the number of origins!")
  }

  #convert percentage to numeric
  perc_sep <- as.numeric(sub("%","",foci_separation))
  perc_sep <- round(perc_sep, digits = 0)

  if(!perc_sep %in% c(0:100)){
    stop("Foci separation should be a value between 1 and 100!")
  }

  poly_tester(poly)

  #backup
  backup_poly <- poly

  poly <- extract_coords(poly)

  #set.seed(1234)
  #generate random points inside the boundary
  ran_points <- as.data.frame(csr(as.matrix(poly,,2), n_origin))
  colnames(ran_points) <- c("x", "y")
  #plot(ran_points$x,ran_points$y)


  if(is.null(restriction_feat)){

    ran_points_pt <- st_as_sf(SpatialPoints(cbind(ran_points$x, ran_points$y),
                           proj4string = raster::projection(backup_poly, FALSE)))

    final_ran_points_pt <- ran_points_pt
    }

  if(!is.null(restriction_feat)){

    #loop through
    restriction_feat <- st_as_sf(restriction_feat)
    #convert xy to points
    ran_points_pt <- st_as_sf(SpatialPoints(cbind(ran_points$x, ran_points$y),
                                proj4string = raster::projection(restriction_feat, FALSE)))
    #check those intersecting land use
    pt_intersect <- unique(data.frame(st_intersects(ran_points_pt, restriction_feat))[,1])
    new_ran_points_pt <- ran_points_pt[-pt_intersect,]

    #check if any of the point intersects
    #restriction feature across the space.
    final_ran_points_pt <- new_ran_points_pt

    #loop until there is exactly number
    #of specified origin points
    while(nrow(final_ran_points_pt) < n_origin){

      #simulate another set of points
      #generate random points inside the boundary
      ran_points <- as.data.frame(csr(as.matrix(poly,,2), n_origin))
      colnames(ran_points) <- c("x", "y")
      #convert to points and check intersection
      ran_points_pt <- st_as_sf(SpatialPoints(cbind(ran_points$x, ran_points$y),
                                              proj4string = raster::projection(restriction_feat, FALSE)))
      #check those not intersecting land use
      pt_intersect <- unique(data.frame(st_intersects(ran_points_pt, restriction_feat))[,1])
      new_ran_points_pt <- ran_points_pt[-pt_intersect,]

      #add to existing list
      final_ran_points_pt <- rbind(final_ran_points_pt, new_ran_points_pt)
    }

    #check if the number of point is greater
    #than specified number
    if(nrow(final_ran_points_pt) > n_origin){
      final_ran_points_pt <- final_ran_points_pt[1:(nrow(final_ran_points_pt) -
                                          ((nrow(final_ran_points_pt) - n_origin))),]
      }
  }

  #add xy coordinates
  final_ran_points_pt$x <- st_coordinates(final_ran_points_pt)[,1]
  final_ran_points_pt$y <- st_coordinates(final_ran_points_pt)[,2]
  #collate cood only
  final_ran_points_pt <- final_ran_points_pt %>%
    as.data.frame() %>%
    dplyr::select(c(x, y))

  if(!is.null(mfocal)){
    #append the mfocal
    final_ran_points_pt[nrow(final_ran_points_pt),1] <- mfocal[1]
    final_ran_points_pt[nrow(final_ran_points_pt),2] <- mfocal[2]
    #set the last record as the main
    #main focal point
    idx <- nrow(final_ran_points_pt)
  }

  if(is.null(mfocal)){
    #randomly pick one point as the
    #main focal point
    idx <- sample(1:nrow(final_ran_points_pt), 1, replace=FALSE)
  }

  #calculate distances between points
  o_dist <- dist(final_ran_points_pt, method = "euclidean", upper=TRUE, diag = TRUE)


  #now sort the dist matrix from selected points
  dist_to_main_focus <- as.matrix(o_dist)[,idx]
  #order of proximity
  dist_to_main_focus <- dist_to_main_focus[order(dist_to_main_focus)]
  idx_others <- names(dist_to_main_focus)

  separation_list <- data.frame(cbind(sn=0:10, val=10:0))

  list_to_pick_from <- length(dist_to_main_focus) -
    (floor(length(dist_to_main_focus)/11)*separation_list[which(separation_list$sn ==
                             round(perc_sep/10, digits=0)),2])
  #then pick random 'n_foci' from the 'list_to_p....'
  ##set.seed(2000)
  n_foci_centre <- sample(idx_others[1:list_to_pick_from], n_foci, replace =FALSE)

  #set as kmean centroids
  #group with 1 iteration
  suppressWarnings(
  groups <- kmeans(final_ran_points_pt,
                   final_ran_points_pt[as.numeric(n_foci_centre),],
                   iter.max = 1, nstart = 1,
         algorithm = "Lloyd", trace=FALSE))

  #now collate members of each group
  #assign probablity value
  groups_clusters <- data.frame(cbind(final_ran_points_pt, group=groups$cluster))

  #append origin category
  groups_clusters <- groups_clusters %>%
    mutate(category = if_else(row_number() %in% as.numeric(n_foci_centre),
                              paste("focal_pt"), paste("others")))

  #if concentration type is "dispersed"
  if(conc_type == "dispersed"){
    #pick each of the focal point
    #and sort their respective 'others'
    #according to the proximity
    group_combined <- NULL

    for(z in 1:length(unique(groups_clusters$group))){ #z<-1

      gr_cut <- groups_clusters %>%
        filter(group == z)

      gr_cut_bk <- gr_cut %>%
        as.data.frame() %>%
        arrange(category)

      #sort to bring the foca_pt up
      gr_cut <- gr_cut %>%
        as.data.frame() %>%
        arrange(category)%>%
        dplyr::select(x, y)
      #dist
      o_dist_gr <- dist(gr_cut, method = "euclidean", upper=TRUE, diag = TRUE)
      o_dist_gr <- as.matrix(o_dist_gr)[1,]

      o_dist_gr <- o_dist_gr[order(o_dist_gr)]

      #in case of 1 row
      if(length(o_dist_gr)==1){
        names(o_dist_gr) <- 1
      }

      #sort the main data
      gr_cut_bk <- cbind(gr_cut_bk[as.numeric(names(o_dist_gr)),],
                         idx=1:nrow(gr_cut_bk))

      group_combined <- rbind(group_combined, gr_cut_bk)
    }

    #create prob
    grp_p <- p_prob(n=nrow(group_combined),
                    p_ratio = p_ratio)
    prob <- rev(grp_p$prob)

    #sort
    final_ran_points_pt_prob <- group_combined %>%
      arrange(idx) %>%
      bind_cols(prob=prob) %>%
      dplyr::select(-c(idx))

  }

  #if concentration type is "nucleated"
  if(conc_type == "nucleated"){
    #Sort in order of proximity to
    #main focal point
    groups_clusters <- groups_clusters[as.numeric(idx_others),]

    #move the main 'focal_pts' to the top
    groups_clusters_focal <- groups_clusters %>%
      filter(category == "focal_pt")
    #others
    groups_clusters_others <- groups_clusters %>%
      filter(category == "others")

    groups_clusters <-
      rbind(groups_clusters_focal, groups_clusters_others)

    grp_p <- p_prob(n=nrow(groups_clusters), p_ratio = p_ratio)

    #append prob. values to random points
    final_ran_points_pt_prob <-
      cbind(groups_clusters, prob=rev(grp_p$prob))
  }

  final_ran_points_pt_prob <- final_ran_points_pt_prob %>%
    select(x, y, prob, group, category)

  p <- ggplot(data = final_ran_points_pt_prob) +
    geom_point(mapping = aes(x = x, y = y, color = category))#+

  origins$origins <- final_ran_points_pt_prob
  origins$mfocal <- mfocal
  origins$plot <- p
  origins$poly <- backup_poly
  origins$Class <- "artif_spo"

  return(origins)

}





