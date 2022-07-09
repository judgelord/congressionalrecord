\name{get_cr_df}
\alias{get_cr_df}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
The main function to get metadata for the Congressional Record for a given date and section (e.g., "house-section" or "senate-section"). This metadata can then be provided to `get_cr_htm()` to download htm files for the desired sections.
}
\description{
Scrape URLs for each subsection of the Congressional Record
As we do so, we retain some helpful metadata

This function puts linked text (`html_nodes("a")`), URLs (`html_attr("href")`) and their text (`html_text()`) for each date and each section of the record into a data frame.
With `map_dfr` from the `purrr` package, it does this to a range of dates.
}
\usage{
get_cr_df(date, section)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{date}{
A vector of dates to scrape in YYYY-MM-DD format
}
  \item{section}{
"senate-section", "house-section", "all"}
}
\details{


}
\value{
A data frame of URLs and metadata for the Congressional Record for specified date(s) and section(s)
}
\references{
https://judgelord.github.io/congressionalrecord/
}
\author{
Devin Judge-Lord}
\note{
 - The record is divided by date
 - The record is divided into three sections: Senate, House, Extensions of Remarks (text submitted to the record later)
 - The page number ("S3253" is the 3,253rd page of the record, featuring remarks from the Senate)

 The Congressional Record has a page for each day: https://www.congress.gov/congressional-record/2017/6/6/senate-section

 On this page are URLs for each subsection. These URLs look like this:
 https://www.congress.gov/congressional-record/2017/6/6/senate-section/article/S3253-6

}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
# example date and section
date <- "2007/03/01"
section <- "senate-section"

## The function is currently defined as
function (date, section)
{
    message(date)
    url <- str_c("https://www.congress.gov/congressional-record",
        date \%>\% str_replace_all("-", "/"), section, sep = "/")
    pages <- read_html(url) \%>\% html_nodes("a")
    d <- tibble(header = html_text(pages), date = date, section = section,
        url = str_c("https://www.congress.gov", html_attr(pages,
            "href"))) \%>\% filter(url \%>\% str_detect("article"))
    return(d)
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
