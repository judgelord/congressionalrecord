\name{extract_names}
\alias{extract_names}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A helper function to extract speakers in the Congressional Record using a regular expression to match how the Record notes speakers.}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
extract_names(file)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file}{
A file path}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
A character string (a regular expression) of speaker names detected in the text of the provided file
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
function (file)
{
    speaker_names <- "(Mr.|Mrs.|Ms.|Miss|HON.) (([A-Z]|\\.| )* |-|)(Mc|Mac|Des|De|La|[A-Z])[A-Z][A-Z]+|The PRESIDING OFFICER|The SPEAKER pro tempore\\.|The SPEAKER pro tempore \\(.*?\\)|The SPEAKER\\.|The ACTING PRESIDENT|The VICE PRESIDENT"
    text <- all_text(file)
    extracted_names <- text \%>\% str_extract_all(speaker_names) \%>\%
        unlist() \%>\% str_remove("\\. [A-Z]$|\\.$") \%>\% str_squish() \%>\%
        str_c(collapse = ";")
    return(extracted_names)
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
