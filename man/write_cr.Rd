\name{write_cr}
\alias{write_cr}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Write txt files parsed by legislator using `extractMemberName() from the `legislators` R package}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
write_cr(cr_date)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cr_date}{
%%     ~~Describe \code{cr_date} here~~
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
function (cr_date)
{
    message(cr_date)
    d <- filter(cr, date == as.Date(cr_date))
    dim(d)
    d$text_head <- d$file \%>\% map_chr(possibly(head_text, otherwise = ""))
    d \%<>\% mutate(speaker = file \%>\% map_chr(possibly(extract_names,
        otherwise = "404error"))) \%>\% mutate(speaker = ifelse(speaker ==
        "", "404error", speaker))
    d \%<>\% parse_text()
    dim(d)
    d \%<>\% mutate(congress = as.numeric(round((year - 2001.1)/2)) +
        107)
    d \%<>\% mutate(chamber = ifelse(chamber == "Extensions of Remarks" &
        str_detect(text_head, "(Mr|Mrs|Ms|Miss)\\. Speaker\\,|in the house of representatives"),
        "House", "Senate"), speaker = speaker \%>\% str_remove("(^|;)(Mr|Mrs|Ms|Miss|HON)(\\.| )") \%>\%
        str_squish())
    d \%<>\% mutate(speaker = ifelse(row_number() > 1 & str_detect(lag(speaker),
        speaker), lag(speaker), speaker))
    d \%<>\% mutate(agency = "cr")
    dim(d)
    d1 <- d \%>\% extractMemberName(col_name = "speaker", members = members)
    dim(d1)
    d1 \%<>\% mutate(file = file \%>\% replace_na("CREC-missing"),
        icpsr = icpsr \%>\% as.character() \%>\% coalesce(speaker) \%>\%
            replace_na("NA"))
    d1 \%<>\% mutate(path = str_c("data", "txt", year, icpsr, str_c(file \%>\%
        str_remove(".htm"), "-", match_id, "-", icpsr, ".txt"),
        sep = "/"))
    make_dir(here::here("data", "txt"))
    walk(str_remove(d1$path, "/[0-9A-Z]*/CREC.*"), .f = make_dir)
    walk(str_remove(d1$path, "/CREC.*"), .f = make_dir)
    walk2(d1$text, d1$path, .f = write_lines)
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
