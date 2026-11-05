sparse_vpts_fixture <- function() {
  path <- system.file("extdata", "example_vpts.csv", package = "bioRad")
  template <- readr::read_csv(path, n_max = 1, na = character(),
                              col_types = readr::cols(.default = readr::col_character()),
                              show_col_types = FALSE)
  data <- template[rep(1, 2500), ]
  data$datetime <- format(as.POSIXct("2022-01-01", tz = "UTC") + seq_len(nrow(data)) * 300,
                          "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  for (field in c("u", "v", "w", "ff", "dd", "sd_vvp")) data[[field]] <- ""
  data$u[2] <- "3.25"
  data$u[4] <- "NaN"
  data$vcp <- ""
  data$source_file <- ""
  data
}

test_that("sparse VPTS measurements and missing states survive either file order", {
  data <- sparse_vpts_fixture()
  paths <- c(tempfile(fileext = ".csv"), tempfile(fileext = ".csv"))
  on.exit(unlink(paths))
  readr::write_csv(data[1:1250, ], paths[1])
  readr::write_csv(data[1251:2500, ], paths[2])
  for (files in list(paths, rev(paths))) {
    result <- read_vpts(files, data_frame = TRUE)
    expect_type(result$u, "double")
    expect_equal(sum(is.finite(result$u)), 1L)
    expect_equal(result$u[is.finite(result$u)], 3.25)
    expect_equal(sum(is.nan(result$u)), 1L)
    expect_equal(sum(is.na(result$u) & !is.nan(result$u)), 2498L)
    expect_type(result$w, "double")
    expect_true(all(is.na(result$w)))
    expect_true(is.numeric(result$vcp))
    expect_type(result$source_file, "character")
    expect_s3_class(result$datetime, "POSIXct")
  }
})

test_that("schema typing also applies to compressed VPTS files", {
  path <- tempfile(fileext = ".csv.gz")
  on.exit(unlink(path))
  readr::write_csv(sparse_vpts_fixture(), path)
  result <- read_vpts(path, data_frame = TRUE)
  expect_equal(result$u[is.finite(result$u)], 3.25)
  expect_equal(sum(is.nan(result$u)), 1L)
})

test_that("schema aliases are typed and extension fields retain inference", {
  types <- vpts_csv_col_types(c("DBZH", "height", "gap", "note"))
  expect_s3_class(types$cols$DBZH, "collector_double")
  expect_s3_class(types$cols$height, "collector_double")
  expect_s3_class(types$cols$gap, "collector_logical")
  expect_s3_class(types$cols$note, "collector_guess")
  expect_named(types$cols, c("DBZH", "height", "gap", "note"))
})
