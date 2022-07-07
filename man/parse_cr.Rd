\name{parse_cr}
\alias{parse_cr}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
The main function to parse .htm Congressional Record files in a directory by speaker and save parsed .txt files in a parallel directory}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
parse_cr(bulk_directory = here::here("data", "htm"), skip_parsed = T, dates = "all")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{bulk_directory}{
%%     ~~Describe \code{bulk_directory} here~~
}
  \item{skip_parsed}{
%%     ~~Describe \code{skip_parsed} here~~
}
  \item{dates}{
%%     ~~Describe \code{dates} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (bulk_directory = here::here("data", "htm"), skip_parsed = T,
    dates = "all")
{
    cr_file <- list.files(bulk_directory)
    cr <- tibble(file = cr_file, year = str_extract(cr_file,
        "[0-9]{4}") \%>\% as.numeric(), date = str_extract(cr_file,
        "[0-9]{4}-[0-9]{2}-[0-9]{2}") \%>\% as.Date())
    cr \%<>\% arrange(date) \%>\% arrange(rev(date))
    if (as.character(dates) == "all") {
        dates <- cr \%>\% filter(year < 2021) \%>\% pull(date) \%>\%
            unique()
    }
    if (skip_parsed == T) {
        cr_parsed <- list.files(bulk_directory \%>\% str_replace("/htm",
            "/txt"), recursive = T)
        length(cr_parsed)
        cr_parsed \%<>\% str_extract("[0-9]{4}-[0-9]{2}-[0-9]{2}") \%<>\%
            unique() \%>\% as.Date()
        length(cr_parsed)
        cr \%<>\% filter(!date \%in\% cr_parsed)
        dim(cr)
    }
    cr \%<>\% mutate(congress = as.numeric(round((year - 2001.1)/2)) +
        107)
    cr \%<>\% mutate(chamber = str_extract(file, "Pg.") \%>\% str_remove("Pg") \%>\%
        str_replace("E", "Extensions of Remarks") \%>\% str_replace("H",
        "House") \%>\% str_replace("S", "Senate"))
    cr \%<>\% mutate(url_txt = str_c("https://www.congress.gov/",
        congress, "/crec/", date \%>\% str_replace_all("-", "/"),
        "/modified/", file))
    walk(.x = unique(dates), .f = write_cr)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
