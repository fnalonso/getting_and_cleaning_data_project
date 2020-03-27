##
# Helper function to download the data file
# parameters:
#   url: HTTP|HTTPS URL to the dataset.
#   local_filename: The path + the filename to save locally. It can have more
#       than one depth level. E.g /home/myuser/data/datafile.zip
#   unzip_data: Should unzip the file after the download ? DEFAULT TRUE
#   overwrite: Overwrite the local file if already exists. DEFAULT FALSE
#   remove_local_file: Removes the local file after download it. It is intented
#       to be used along unzip_data. DEFAULT FALSE
download_data_file <- function(url, local_filename, unzip_data = TRUE, 
                               overwrite = FALSE, remove_local_file = FALSE){
    if(!startsWith(url, "http")) stop("Invalid URL")
    if(file.exists(local_filename) && overwrite == FALSE) 
        stop("The local file already exists. To overwrite it, set the flag 
             `overwrite` = TRUE.")
    
    directory <- dirname(local_filename)
    filename <- basename(local_filename)
    
    if(!dir.exists(directory)) dir.create(directory, recursive = TRUE)
    download.file(url, local_filename)
    
    if(unzip_data == TRUE) {
        cat("Unzipping data...")
        unzip(local_filename, exdir = directory, overwrite = TRUE) 
        cat("Done!")
    }
    if(remove_local_file == TRUE) invisible(file.remove(local_filename))
}
