pm_url <- "http://packagemanager:4242/"
source_name <- "testing-source-r"
src_dir <- "./packages"

# create token on new PPM server beforehand using
# rspm create token --description="Upload packages" \
#                   --sources=name-of-new-source --expires=30d --scope=sources:write 
ppm_token <- ""

# download RSPM binary for API calls
download_rspm_binary <- function(ppm_url = "http://packagemanager:4242", 
                                 token) {
  if (!file.exists("rspm")) {
    tryCatch({
      system_result <- system(
        paste0(
          'rm -f rspm && curl -fLOJH "Authorization: Bearer ',
          token,
          '" "',
          ppm_url,
          '/__api__/download" && chmod +x ./rspm'
        ),
        intern = TRUE
      )
      print(paste(
        "Debug: rspm download result:",
        paste(system_result, collapse = "\n")
      ))
    }, error = function(e) {
      return(list(error = paste(
        "Error downloading rspm:", e$message
      )))
    })
  }
}

upload_package <- function(ppm_url = "http://packagemanager:4242", 
                           source = "testing-source-r", token, file_path) {
  
  Sys.setenv("PACKAGEMANAGER_ADDRESS" = ppm_url)
  Sys.setenv("PACKAGEMANAGER_TOKEN" = token)

  tryCatch({
    {
      system(paste0(
        "./rspm add --source=", source,
        " --path=",
        file_path
      ))
    }
  }, error = function(e) {
    return(list(error = paste(
      "Error uploading package", source, ":", e$message
    )))
  })
}


if (!file.exists("rspm")) download_rspm_binary(ppm_url = pm_url, ppm_token)

files_to_upload <- list.files(path = src_dir, full.names = TRUE)

for (file_path in files_to_upload) {
  print(paste("Uploading package:", file_path))
  upload_package(ppm_url = pm_url, source = source_name,
                 token = ppm_token, file_path = file_path)
}

