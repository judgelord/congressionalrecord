\name{parse_text}
\alias{parse_text}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Map the `parse()` function to a vector of text.}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
parse_text(d)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{d}{
%%     ~~Describe \code{d} here~~
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
function (d)
{
    d$text <- map2(.x = d$speaker, .y = d$file, .f = parse)
    d \%<>\% unnest(text)
    d \%<>\% distinct()
    d \%<>\% mutate(speakers = speaker, speaker = text \%>\% str_extract(".* :::") \%>\%
        str_remove(" :::"))
    d \%<>\% mutate(text_head = text \%>\% str_sub(0, 500) \%>\% str_c("..."))
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
