
getMetaData <- function(
    data.directory = NULL
    ) {

    thisFunctionName <- "getMetaData";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    require(raster);
    require(readxl);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.metadata.spatial <- getMetaData_spatial(
        data.directory = data.directory
        );

    colnames(DF.metadata.spatial) <- gsub(
        x           = colnames(DF.metadata.spatial),
        pattern     = "^geotiff$",
        replacement = "geotiff.downloaded"
        );

    cat("\nDF.metadata.spatial\n");
    print( DF.metadata.spatial   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.metadata.temporal <- getMetaData_temporal(
        data.directory = data.directory
        );

    colnames(DF.metadata.temporal) <- gsub(
        x           = colnames(DF.metadata.temporal),
        pattern     = "^geotiff$",
        replacement = "geotiff.metadata"
        );

    cat("\nDF.metadata.temporal\n");
    print( DF.metadata.temporal   );

    cat("\nunique(DF.metadata.temporal[,'geotiff.metadata'])\n");
    print( unique(DF.metadata.temporal[,'geotiff.metadata'])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.metadata <- dplyr::left_join(
        x  = DF.metadata.spatial,
        y  = DF.metadata.temporal,
        by = "year"
        );

    reordered.colnames <- c(
        colnames(DF.metadata.temporal),
        setdiff(colnames(DF.metadata.spatial),'year')
        );

    DF.metadata <- DF.metadata[,reordered.colnames];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.metadata );

    }

##################################################
getMetaData_julian.day1 <- function(
    year = NULL
    ){
    gregorian.week1    <- base::as.Date(base::paste0(year,"-01-01")) + base::seq(0,6);
    gregorian.weekdays <- base::weekdays(gregorian.week1);
    julian.day1        <- gregorian.week1[gregorian.weekdays == "Monday"];
    return( julian.day1 );
    }

getMetaData_temporal <- function(
    data.directory = NULL
    ) {

    require(readxl);

    # cat("\nlist.files(data.directory, pattern = '\\.xlsx$')\n");
    # print( list.files(data.directory, pattern = '\\.xlsx$')   );

  # FILE.band.week <- list.files(path = data.directory, pattern = '\\.xlsx$');
    FILE.band.week <- list.files(path = data.directory, pattern = '-AC-\\.xlsx$');
    PATH.band.week <- file.path(data.directory,FILE.band.week);

    sheet.names    <- readxl::excel_sheets(path = PATH.band.week);
    sheet.names    <- grep(x = sheet.names, pattern = "^[0-9]{4}$", value = TRUE);

    cat("\nsheet.names\n");
    print( sheet.names   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # DF.output <- data.frame();

    temp.years <- as.integer(seq(1987,1999));
    temp.julian.day1s <- do.call(
        what = base::c,
        args = sapply(
            X        = temp.years,
            FUN      = getMetaData_julian.day1,
            simplify = FALSE
            )
        );

    DF.output <- data.frame(
        year         = temp.years,
        julian.day1  = temp.julian.day1s,
        geotiff      = as.character(rep(NA,length(temp.years))),
        band         = as.character(rep(-1,length(temp.years))),
        julian.week  = as.integer(  rep(NA,length(temp.years)))
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.sheet in sheet.names ) {

        DF.temp <- base::as.data.frame(readxl::read_excel(
            path  = PATH.band.week,
            sheet = temp.sheet
            ));
        temp.geotiff <- paste0(colnames(DF.temp)[2],".tif");
        band.row.index <- grep(
            x           = DF.temp[,1],
            pattern     = "bands",
            ignore.case = TRUE
            );
        DF.temp <- DF.temp[seq(band.row.index+1,nrow(DF.temp)),c(1,2)];
        colnames(DF.temp) <- c('band','julian.week');

        DF.temp[,'julian.week'] <- as.integer(DF.temp[,'julian.week']);
        DF.temp[,'year']        <- as.integer(temp.sheet);
        DF.temp[,'geotiff']     <- temp.geotiff;
        DF.temp[,'julian.day1'] <- getMetaData_julian.day1(year = temp.sheet);

        DF.temp <- DF.temp[,c('year','julian.day1','geotiff','band','julian.week')];
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

    require(raster);

    # cat("\nlist.files(data.directory, pattern = '\\.tif$')\n");
    # print( list.files(data.directory, pattern = '\\.tif$')   );

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

    return( DF.geotiffs );

    }
