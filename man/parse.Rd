\name{parse}
\alias{parse}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Parse the congressional record by speaker}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
parse(speaker_list, file)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{speaker_list}{
%%     ~~Describe \code{speaker_list} here~~
}
  \item{file}{
%%     ~~Describe \code{file} here~~
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
function (speaker_list, file)
{
    speaker_list \%<>\% escape_specials()
    text <- all_text(file)
    text <- str_c(":::", text)
    speaker_pattern <- speaker_list \%>\% str_replace_all(";",
        "|")
    t <- text \%>\% str_split(speaker_pattern) \%>\% unlist()
    extracted <- text \%>\% str_extract_all(speaker_pattern) \%>\%
        unlist()
    s <- c("header", extracted) \%>\% str_c(" :::")
    speech <- map2(.x = s, .y = t, .f = paste)
    return(speech)
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
