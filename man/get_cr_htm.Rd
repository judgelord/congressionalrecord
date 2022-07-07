\name{get_cr_htm}
\alias{get_cr_htm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A function to download htm files of the Congressional Record for a given url address)}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
get_cr_htm(url)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{url}{
%%     ~~Describe \code{url} here~~
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
function (url)
{
    url \%<>\% html_session() \%>\% follow_link("View TXT in new window")
    file <- str_remove(url$url, ".*modified/")
    if (!file \%in\% downloaded) {
        read_html(url) \%>\% write_html(file = here::here("data",
            "htm", file))
    }
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
