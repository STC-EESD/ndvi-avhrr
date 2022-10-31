
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
        year    = as.numeric(stringr::str_extract(string = geotiffs, pattern = "[0-9]{4}")),
        geotiff = geotiffs,
        n.x     = numeric(  length = n.geotiffs),
        n.y     = numeric(  length = n.geotiffs),
        x.min   = numeric(  length = n.geotiffs),
        x.max   = numeric(  length = n.geotiffs),
        y.min   = numeric(  length = n.geotiffs),
        y.max   = numeric(  length = n.geotiffs),
        crs     = character(length = n.geotiffs)
        );
    DF.geotiffs <- DF.geotiffs[order(DF.geotiffs[,'year']),];
    rownames(DF.geotiffs) <- NULL;

    for ( row.index in seq(1,nrow(DF.geotiffs)) ) {
        temp.path   <- file.path(data.directory,DF.geotiffs[row.index,'geotiff']);
        temp.raster <- raster::raster(temp.path);
        temp.coords <- raster::coordinates(temp.raster);
        unique.x    <- unique(temp.coords[,1]);
        unique.y    <- unique(temp.coords[,2]);
        DF.geotiffs[row.index,'n.x']   <- length(unique.x);
        DF.geotiffs[row.index,'n.y']   <- length(unique.y);
        DF.geotiffs[row.index,'x.min'] <- min(unique.x);
        DF.geotiffs[row.index,'x.max'] <- max(unique.x);
        DF.geotiffs[row.index,'y.min'] <- min(unique.y);
        DF.geotiffs[row.index,'y.max'] <- max(unique.y);
        DF.geotiffs[row.index,'crs']   <- as.character(raster::crs(temp.raster));
        }

    cat("\nDF.geotiffs\n");
    print( DF.geotiffs   );

    cat("\nunique(DF.geotiffs[,setdiff(colnames(DF.geotiffs),c('year','geotiff'))])\n");
    print( unique(DF.geotiffs[,setdiff(colnames(DF.geotiffs),c('year','geotiff'))])   );

    return( NULL );

    }
