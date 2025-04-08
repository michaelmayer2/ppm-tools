library(httr)

pm_url <- "http://packagemanager:4242/"
repo_name <- "tested-r"
dest_dir <- "./packages"


# list all package names in repo
response <- GET(
  url = paste0(pm_url,"__api__/repos/", repo_name, "/packages"),
  accept("application/json")
)
json_content <- content(response, as = "parsed")

if (!is.null(json_content) && length(json_content) > 0) {
  names <- sapply(json_content,
                  function(item) item$name)
} else {
  names <- NA
}

download_urls <- function(pm_url, repo_name,
                          main_name, main_version,
                          archived_names, archived_versions) {

  urls <- c(paste0(pm_url, repo_name, "/latest/src/contrib/",
                   main_name, "_", main_version, ".tar.gz"))

  cat(paste(main_name,main_version, ": Version found\n"))
  if (!all(is.na(archived_names))) {
    for (i in seq_along(archived_names)) {
      urls <- c(urls, paste0(pm_url, repo_name, "/latest/src/contrib/Archive/",
                             archived_names[i], "/",
                             archived_names[i], "_",
                             archived_versions[i], ".tar.gz"))
      cat(paste(main_name,main_version,
                ": Archived Version", archived_versions[i], "found\n"))
    }
  } else {
    cat(paste(main_name, main_version, ": Archived Version does not exist\n"))
  }
  urls
}

download_list <- c()

for (i in seq_along(names)) {

  # Choose a package to download
  package_to_download <- names[i]

  # Construct the URL for downloading the package
  download_url <- paste0(pm_url, "__api__/repos/", 
                         repo_name, "/packages/", package_to_download)

  # Download the package
  response <- GET(download_url)

  # Parse the response content as JSON
  json_content <- content(response, as = "parsed")

  # Extract 'name' and 'version' from the main JSON
  main_name <- json_content$name
  main_version <- json_content$version

  # Extract 'name' and 'version' from the 'archived' list, if it exists
  if (!is.null(json_content$archived) && length(json_content$archived) > 0) {
    archived_names <- sapply(json_content$archived,
                             function(item) item$name)
    archived_versions <- sapply(json_content$archived,
                                function(item) item$version)
  } else {
    archived_names <- NA
    archived_versions <- NA
  }

  download_list <- c(download_list, 
                     download_urls(pm_url, repo_name,
                     main_name, main_version,
                     archived_names, archived_versions))

}

# Function to download files using httr
download_files <- function(urls) {
  for (url in urls) {
    # Extract the file name from the URL
    file_name <- basename(url)

    # Perform the GET request and write the response content to a file
    if (!dir.exists(dest_dir)) dir.create(dest_dir)
    response <- GET(url, write_disk(file.path(dest_dir, file_name),
                                    overwrite = TRUE))

    # Check if the request was successful
    if (status_code(response) == 200) {
      cat("Downloaded:", file_name, "\n")
    } else {
      cat("Failed to download:", file_name, "\n")
    }
  }
}

# Call the function with the download_list
download_files(download_list)