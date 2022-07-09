\name{keyword_sentence}
\alias{keyword_sentence}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Pull sentences that mention given keywords from text files}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
keyword_sentence(file, word)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file}{
%%     ~~Describe \code{file} here~~
}
  \item{word}{
%%     ~~Describe \code{word} here~~
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
function (file, word)
{
    text <- read_lines(here::here(file)) \%>\% str_c(collapse = " ") \%>\%
        str_squish()
    if (str_detect(text, regex(word, ignore_case = T))) {
        text \%<>\% enframe(name = NULL, value = "text") \%>\% unnest_tokens(sentence,
            text, token = "sentences") \%>\% filter(str_detect(sentence,
            word)) \%>\% .$sentence \%>\% str_c(collapse = "...")
    }
    else {
        text <- NA
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
