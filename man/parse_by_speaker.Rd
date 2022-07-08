\name{parse_by_speaker}
\alias{parse_by_speaker}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A helper function to parse files with more than one speaker
}
\description{
This is a function used by `parse_cr`.
It takes takes a vector of regular expressions (`speaker_list`) and a file path (`file`).
It uses the `all_text` function to read the text file.
It uses the `escape_specials` function to clean the speaker list and creates a regular expression of strings (speaker names) at which to split the text.
Finally it splits the text by speakerand returns a vector of speeches.
}
\usage{
parse_by_speaker(speaker_list, file)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{speaker_list}{
%%     ~~Describe \code{speaker_list} here~~
}
  \item{file}{
A path to a txt file to be paresed
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
A character vector of texts parsed by speaker
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Devin Judge-Lord
}
\note{
This is a helper function for the main user-facing function `cr_parse()`
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{

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
