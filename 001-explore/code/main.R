
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);

print(   data.directory );
print(   code.directory );
print( output.directory );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

# set working directory to output directory
setwd( output.directory );

##################################################
require(arrow);
require(ggplot2);
require(ncdf4);
require(raster);
require(readxl);
require(sf);
require(stringr);
require(terrainr);
require(tidyr);
require(zoo);

# require(openssl);
# require(tidyquant);

# source supporting R code
code.files <- c(
    "getMetaData.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

is.macOS  <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
n.cores   <- ifelse(test = is.macOS, yes = 2, no = parallel::detectCores() - 1);
cat(paste0("\n# n.cores = ",n.cores,"\n"));

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
data.directory <- gsub(
    x           = output.directory,
    pattern     = "001-explore",
    replacement = base::file.path("000-data","001-ndvi-avhrr")
    );

data.directory <- gsub(
    x           = data.directory,
    pattern     = "output",
    replacement = ifelse(test = is.macOS, yes = "output.2022-10-15.01", no = "output.2022-10-20.01")
    );

print( data.directory );
print( dir.exists(data.directory) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.metadata <- getMetaData(
    data.directory = data.directory
    );

cat("\nDF.metadata[!is.na(DF.metadata[,'geotiff.downloaded']),]\n");
print( DF.metadata[!is.na(DF.metadata[,'geotiff.downloaded']),]   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
