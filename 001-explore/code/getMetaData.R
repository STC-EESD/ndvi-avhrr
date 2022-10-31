
getMetaData <- function(
    data.directory = NULL
    ) {

    thisFunctionName <- "getMetaData";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # DF.metadata.spatial <- getMetaData_spatial(
    #     data.directory = data.directory
    #     );
    #
    # cat("\nDF.metadata.spatial\n");
    # print( DF.metadata.spatial   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.metadata.temporal <- getMetaData_temporal(
        data.directory = data.directory
        );

    cat("\nDF.metadata.temporal\n");
    print( DF.metadata.temporal   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
getMetaData_temporal <- function(
    data.directory = NULL
    ) {

    require(readxl);

    cat("\nlist.files(data.directory, pattern = '\\.xlsx$')\n");
    print( list.files(data.directory, pattern = '\\.xlsx$')   );

    FILE.band.week <- list.files(path = data.directory, pattern = '\\.xlsx$');
    PATH.band.week <- file.path(data.directory,FILE.band.week);

    sheet.names    <- readxl::excel_sheets(path = PATH.band.week);
    sheet.names    <- grep(x = sheet.names, pattern = "^[0-9]{4}$", value = TRUE);

    cat("\nsheet.names\n");
    print( sheet.names   );

    DF.output <- data.frame();
    for ( temp.sheet in sheet.names ) {

        DF.temp <- base::as.data.frame(readxl::read_excel(
            path  = PATH.band.week,
            sheet = temp.sheet
            ));
        band.row.index <- grep(
            x           = DF.temp[,1],
            pattern     = "bands",
            ignore.case = TRUE
            );
        DF.temp <- DF.temp[seq(band.row.index+1,nrow(DF.temp)),c(1,2)];
        colnames(DF.temp)   <- c('band','julian.week');

        DF.temp[,'julian.week'] <- as.integer(DF.temp[,'julian.week']);
        DF.temp[,'year']        <- as.integer(temp.sheet);
        DF.temp[,'geotiff']     <- FILE.band.week;

        gregorian.week1         <- as.Date(paste0(temp.sheet,"-01-01")) + seq(0,6);
        gregorian.weekdays      <- base::weekdays(gregorian.week1);
        julian.day1             <- gregorian.week1[gregorian.weekdays == "Monday"];
        DF.temp[,'julian.day1'] <- julian.day1;

        DF.temp <- DF.temp[,c('year','geotiff','band','julian.day1','julian.week')];
        DF.output <- rbind(DF.output,DF.temp);

        cat("\nsheet:",temp.sheet);
        cat("\nstr(DF.temp)\n");
        print( str(DF.temp)   );

        }

    DF.output[,'julian.week'] <- as.integer(DF.output[,'julian.week']);
    DF.output[,'julian.date'] <- DF.output[,'julian.day1'] + 7 * (-1 + DF.output[,'julian.week']);
    DF.output                 <- DF.output[order(DF.output[,'julian.date']),];
    DF.output[,'check']       <- base::weekdays(DF.output[,'julian.date']);

    return( DF.output );

    }

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
