
getMetaData <- function(
    data.directory = NULL
    ) {

    thisFunctionName <- "getMetaData";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.metadata.spatial <- getMetaData_spatial(
        data.directory = data.directory
        );

    cat("\nDF.metadata.spatial\n");
    print( DF.metadata.spatial   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
getMetaData_spatial <- function(
    data.directory = NULL
    ) {

    cat("\nlist.files(data.directory, pattern = '\\.tif$')\n");
    print( list.files(data.directory, pattern = '\\.tif$')   );

    geotiffs   <- list.files(path = data.directory, pattern = '\\.tif$');
    n.geotiffs <- length(geotiffs);

    DF.geotiffs <- data.frame(
        year     = as.numeric(stringr::str_extract(string = geotiffs, pattern = "[0-9]{4}")),
        geotiff  = geotiffs,
        n.layers = integer(  length = n.geotiffs),
        n.x      = integer(  length = n.geotiffs),
        n.y      = integer(  length = n.geotiffs),
        x.min    = integer(  length = n.geotiffs),
        x.max    = integer(  length = n.geotiffs),
        y.min    = integer(  length = n.geotiffs),
        y.max    = integer(  length = n.geotiffs),
        crs      = character(length = n.geotiffs)
        );
    DF.geotiffs <- DF.geotiffs[order(DF.geotiffs[,'year']),];
    rownames(DF.geotiffs) <- NULL;

    for ( row.index in seq(1,nrow(DF.geotiffs)) ) {
        temp.path   <- base::file.path(data.directory,DF.geotiffs[row.index,'geotiff']);
        temp.brick <- raster::brick(temp.path);
        temp.coords <- raster::coordinates(temp.brick);
        unique.x    <- base::unique(temp.coords[,1]);
        unique.y    <- base::unique(temp.coords[,2]);
        DF.geotiffs[row.index,'n.layers'] <- raster::nlayers(temp.brick);
        DF.geotiffs[row.index,'n.x'     ] <- base::length(unique.x);
        DF.geotiffs[row.index,'n.y'     ] <- base::length(unique.y);
        DF.geotiffs[row.index,'x.min'   ] <-    base::min(unique.x);
        DF.geotiffs[row.index,'x.max'   ] <-    base::max(unique.x);
        DF.geotiffs[row.index,'y.min'   ] <-    base::min(unique.y);
        DF.geotiffs[row.index,'y.max'   ] <-    base::max(unique.y);
        DF.geotiffs[row.index,'crs'     ] <- base::as.character(raster::crs(temp.brick));
        }

    cat("\nDF.geotiffs\n");
    print( DF.geotiffs   );

    cat("\nunique(DF.geotiffs[,setdiff(colnames(DF.geotiffs),c('year','geotiff','n.layers'))])\n");
    print( unique(DF.geotiffs[,setdiff(colnames(DF.geotiffs),c('year','geotiff','n.layers'))])   );

    return( NULL );

    }
