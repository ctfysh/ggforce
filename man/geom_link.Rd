% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/link.R
\name{geom_link}
\alias{geom_link}
\alias{geom_link2}
\alias{stat_link}
\alias{stat_link2}
\title{Link points with paths}
\usage{
stat_link(mapping = NULL, data = NULL, geom = "path",
  position = "identity", na.rm = FALSE, show.legend = NA, n = 100,
  inherit.aes = TRUE, ...)

stat_link2(mapping = NULL, data = NULL, geom = "path_interpolate",
  position = "identity", na.rm = FALSE, show.legend = NA, n = 100,
  inherit.aes = TRUE, ...)

geom_link(mapping = NULL, data = NULL, stat = "link",
  position = "identity", arrow = NULL, lineend = "butt", na.rm = FALSE,
  show.legend = NA, inherit.aes = TRUE, n = 100, ...)

geom_link2(mapping = NULL, data = NULL, stat = "link2",
  position = "identity", arrow = NULL, lineend = "butt", na.rm = FALSE,
  show.legend = NA, inherit.aes = TRUE, n = 100, ...)
}
\arguments{
\item{mapping}{Set of aesthetic mappings created by \code{\link[ggplot2]{aes}}
or \code{\link[ggplot2]{aes_}}. If specified and \code{inherit.aes = TRUE}
(the default), is combined with the default mapping at the top level of the
plot. You only need to supply mapping if there isn't a mapping defined for
the plot.}

\item{data}{A data frame. If specified, overrides the default data frame
defined at the top level of the plot.}

\item{geom, }{stat Override the default connection between \code{geom_arc} and
\code{stat_arc}.}

\item{position}{Position adjustment, either as a string, or the result of a
call to a position adjustment function.}

\item{na.rm}{If \code{FALSE} (the default), removes missing values with a
warning. If \code{TRUE} silently removes missing values.}

\item{show.legend}{logical. Should this layer be included in the legends?
\code{NA}, the default, includes if any aesthetics are mapped. \code{FALSE}
never includes, and \code{TRUE} always includes.}

\item{n}{The number of points to create for each segment}

\item{inherit.aes}{If \code{FALSE}, overrides the default aesthetics, rather
than combining with them. This is most useful for helper functions that
define both data and aesthetics and shouldn't inherit behaviour from the
default plot specification, e.g. borders.}

\item{...}{other arguments passed on to \code{\link[ggplot2]{layer}}. There
are three types of arguments you can use here:
\itemize{
 \item{Aesthetics: to set an aesthetic to a fixed value, like
 \code{color = "red"} or \code{size = 3.}}
 \item{Other arguments to the layer, for example you override the default
 \code{stat} associated with the layer.}
 \item{Other arguments passed on to the stat.}
}}

\item{arrow}{specification for arrow heads, as created by arrow()}

\item{lineend}{Line end style (round, butt, square)}
}
\description{
This set of geoms makes it possible to connect points using straight lines.
Before you think \code{\link[ggplot2]{geom_segment}} and
\code{\link[ggplot2]{geom_path}}, these functions have some additional tricks
up their sleeves. geom_link connects two points in the same way as
\code{\link[ggplot2]{geom_segment}} but does so by interpolating multiple
points between the two. An additional column called index is added to the
data with a sequential progression of the interpolated points. This can be
used to map color or size to the direction of the link. geom_link2 uses the
same syntax as \code{\link[ggplot2]{geom_path}} but interpolates between the
aesthetics given by each row in the data.
}
\section{Aesthetics}{

geom_link understand the following aesthetics (required aesthetics are in
bold):
\itemize{
 \item{\strong{x}}
 \item{\strong{y}}
 \item{\strong{xend}}
 \item{\strong{yend}}
 \item{color}
 \item{size}
 \item{linetype}
 \item{alpha}
 \item{lineend}
}
geom_link2 understand the following aesthetics (required aesthetics are in
bold):
\itemize{
 \item{\strong{x}}
 \item{\strong{y}}
 \item{color}
 \item{size}
 \item{linetype}
 \item{alpha}
 \item{lineend}
}
}

\section{Computed variables}{


\describe{
 \item{x, y}{The interpolated point coordinates}
 \item{index}{The progression along the interpolation mapped between 0 and 1}
}
}
\examples{
# Lets make some data
lines <- data.frame(
  x = c(5, 12, 15, 9, 6),
  y = c(17, 20, 4, 15, 5),
  xend = c(19, 17, 2, 9, 5),
  yend = c(10, 18, 7, 12, 1),
  width = c(1, 10, 6, 2, 3),
  colour = letters[1:5]
)

ggplot() + geom_link(aes(x = x, y = y, xend = xend, yend = yend,
                         colour = colour, alpha = ..index..,
                         size = ..index..),
                     data = lines)

ggplot() + geom_link2(aes(x = x, y = y, colour = colour, size = width,
                          group = 1),
                      data = lines, lineend = 'round', n = 500)

}
\author{
Thomas Lin Pedersen
}

