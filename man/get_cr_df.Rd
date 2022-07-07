\name{get_cr_df}
\alias{get_cr_df}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
The main function to get metadata for the Congressional Record for a given date and section (e.g., "house-section" or "senate-section"). This metadata can then be provided to `get_cr_htm()` to download htm files for the desired sections.
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
get_cr_df(date, section)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{date}{
%%     ~~Describe \code{date} here~~
}
  \item{section}{
%%     ~~Describe \code{section} here~~
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
