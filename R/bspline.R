#' B-splines based on control points
#'
#' This set of stats and geoms makes it possible to draw b-splines based on a
#' set of control points. As with \code{\link{geom_bezier}} there exists several
#' versions each having there own strengths. The base version calculates the
#' b-spline as a number of points along the spline and connects these with a
#' path. The *2 version does the same but in addition interpolates aesthetics
#' between each control point. This makes the *2 version considerably slower
#' so it shouldn't be used unless needed. The *0 version uses
#' \code{\link[grid]{xsplineGrob}} with \code{shape = 1} to approximate a
#' b-spline for a high performant version.
#'
#' @section Aesthetics:
#' geom_edge_bundle understand the following aesthetics (required aesthetics are in
#' bold):
#' \itemize{
#'  \item{\strong{x}}
#'  \item{\strong{y}}
#'  \item{color}
#'  \item{size}
#'  \item{linetype}
#'  \item{alpha}
#'  \item{lineend}
#' }
#'
#' @section Computed variables:
#'
#' \describe{
#'  \item{x, y}{The coordinates for the path describing the spline}
#'  \item{index}{The progression along the interpolation mapped between 0 and 1}
#' }
#'
#' @param mapping Set of aesthetic mappings created by \code{\link[ggplot2]{aes}}
#' or \code{\link[ggplot2]{aes_}}. If specified and \code{inherit.aes = TRUE}
#' (the default), is combined with the default mapping at the top level of the
#' plot. You only need to supply mapping if there isn't a mapping defined for
#' the plot.
#'
#' @param data A data frame. If specified, overrides the default data frame
#' defined at the top level of the plot.
#'
#' @param position Position adjustment, either as a string, or the result of a
#' call to a position adjustment function.
#'
#' @param arrow specification for arrow heads, as created by arrow()
#'
#' @param lineend Line end style (round, butt, square)
#'
#' @param n The number of points generated for each spline
#'
#' @param ... other arguments passed on to \code{\link[ggplot2]{layer}}. There
#' are three types of arguments you can use here:
#' \itemize{
#'  \item{Aesthetics: to set an aesthetic to a fixed value, like
#'  \code{color = "red"} or \code{size = 3.}}
#'  \item{Other arguments to the layer, for example you override the default
#'  \code{stat} associated with the layer.}
#'  \item{Other arguments passed on to the stat.}
#' }
#'
#' @param na.rm If \code{FALSE} (the default), removes missing values with a
#' warning. If \code{TRUE} silently removes missing values.
#'
#' @param show.legend logical. Should this layer be included in the legends?
#' \code{NA}, the default, includes if any aesthetics are mapped. \code{FALSE}
#' never includes, and \code{TRUE} always includes.
#'
#' @param inherit.aes If \code{FALSE}, overrides the default aesthetics, rather
#' than combining with them. This is most useful for helper functions that
#' define both data and aesthetics and shouldn't inherit behaviour from the
#' default plot specification, e.g. borders.
#'
#' @param geom, stat Override the default connection between \code{geom_arc} and
#' \code{stat_arc}.
#'
#' @author Thomas Lin Pedersen. The C++ code for De Boor's algorithm has been
#' adapted from
#' \href{https://chi3x10.wordpress.com/2009/10/18/de-boor-algorithm-in-c/}{Jason Yu-Tseh Chi implementation}
#'
#' @references Holten, D. (2006). \emph{Hierarchical edge bundles: visualization
#' of adjacency relations in hierarchical data.} IEEE Transactions on
#' Visualization and Computer Graphics, \strong{12}(5), 741-748.
#' http://doi.org/10.1109/TVCG.2006.147
#'
#' @name geom_bspline
#' @rdname geom_bspline
#'
#' @examples
#' # Define some control points
#' cp <- data.frame(
#'   x = c(0, -5, -5, 5, 5, 2.5, 5, 7.5, 5, 2.5, 5, 7.5, 5, -2.5, -5, -7.5, -5,
#'         -2.5, -5, -7.5, -5),
#'   y = c(0, -5, 5, -5, 5, 5, 7.5, 5, 2.5, -5, -7.5, -5, -2.5, 5, 7.5, 5, 2.5,
#'         -5, -7.5, -5, -2.5),
#'   class = sample(letters[1:3], 21, replace = TRUE)
#' )
#'
#' # Now create some paths between them
#' paths <- data.frame(
#'   ind = c(7,5,8,8,5,9,9,5,6,6,5,7,7,5,1,3,15,8,5,1,3,17,9,5,1,2,19,6,5,1,4,
#'           12,7,5,1,4,10,6,5,1,2,20),
#'   group = c(1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,
#'             9,9,9,9,9,10,10,10,10,10)
#' )
#' paths$x <- cp$x[paths$ind]
#' paths$y <- cp$y[paths$ind]
#' paths$class <- cp$class[paths$ind]
#'
#' ggplot() +
#'   geom_bspline(aes(x=x, y=y, group=group, colour = ..index..), data=paths) +
#'   geom_point(aes(x=x, y=y), data=cp, color='steelblue')
#'
#' ggplot() +
#'   geom_bspline2(aes(x=x, y=y, group=group, colour = class), data=paths) +
#'   geom_point(aes(x=x, y=y), data=cp, color='steelblue')
#'
#' ggplot() +
#'   geom_bspline0(aes(x=x, y=y, group=group), data=paths) +
#'   geom_point(aes(x=x, y=y), data=cp, color='steelblue')
#'
NULL


#' @rdname ggforce-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggplot2 ggproto Stat
#' @importFrom dplyr %>% group_by_ do
#' @export
StatBspline <- ggproto('StatBspline', Stat,
    compute_layer = function(self, data, params, panels) {
        if (is.null(data)) return(data)
        data <- data[order(data$group),]
        paths <- getSplines(data$x, data$y, data$group, params$n)
        paths <- data.frame(x = paths$paths[,1], y = paths$paths[,2], group = paths$pathID)
        paths$index <- rep(seq(0, 1, length.out = params$n), length(unique(data$group)))
        dataIndex <- rep(match(unique(data$group), data$group), each = params$n)
        cbind(paths, data[dataIndex, !names(data) %in% c('x', 'y', 'group'), drop = FALSE])
    },
    required_aes = c('x', 'y'),
    extra_params = c('na.rm', 'n')
)
#' @rdname geom_bspline
#' @importFrom ggplot2 layer
#' @export
stat_bspline <- function(mapping = NULL, data = NULL, geom = "path",
                             position = "identity", na.rm = FALSE, n = 100,
                             show.legend = NA, inherit.aes = TRUE, ...) {
    layer(
        stat = StatBspline, data = data, mapping = mapping, geom = geom,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, n=n, ...)
    )
}
#' @rdname geom_bspline
#' @importFrom ggplot2 layer
#' @export
geom_bspline <- function(mapping = NULL, data = NULL, stat = "bspline",
                     position = "identity", arrow = NULL, n = 100,
                     lineend = "butt", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, ...) {
    layer(data = data, mapping = mapping, stat = stat, geom = GeomPath,
          position = position, show.legend = show.legend, inherit.aes = inherit.aes,
          params = list(arrow = arrow, lineend = lineend, na.rm = na.rm, n=n, ...))
}
#' @rdname ggforce-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggplot2 ggproto Stat
#' @importFrom dplyr %>% group_by_ do
#' @export
StatBspline2 <- ggproto('StatBspline2', Stat,
    compute_layer = function(self, data, params, panels) {
        if (is.null(data)) return(data)
        data <- data[order(data$group),]
        nControls <- table(data$group)
        paths <- getSplines(data$x, data$y, data$group, params$n)
        paths <- data.frame(x = paths$paths[,1], y = paths$paths[,2], group = paths$pathID)
        paths$index <- rep(seq(0, 1, length.out = params$n), length(unique(data$group)))
        dataIndex <- rep(match(unique(data$group), data$group), each = params$n)
        paths <- cbind(paths, data[dataIndex, 'PANEL', drop = FALSE])
        extraCols <- !names(data) %in% c('x', 'y', 'group', 'PANEL')
        pathIndex <- match(unique(data$group), paths$group)
        pathIndex <- unlist(Map(seq, from = pathIndex, length.out = nControls))
        paths$.interp <- TRUE
        paths$.interp[pathIndex] <- FALSE
        if (any(extraCols)) {
            for (i in names(data)[extraCols]) {
                paths[[i]] <- NA
                if (is.factor(data[[i]])) {
                    paths[[i]] <- as.factor(paths[[i]])
                    levels(paths[[i]]) <- levels(data[[i]])
                }
                paths[[i]][pathIndex] <- data[, i]
            }
        }
        paths
    },
    required_aes = c('x', 'y'),
    extra_params = c('na.rm', 'n')
)
#' @rdname geom_bspline
#' @importFrom ggplot2 layer
#' @export
stat_bspline2 <- function(mapping = NULL, data = NULL, geom = "path_interpolate",
                         position = "identity", na.rm = FALSE, n = 100,
                         show.legend = NA, inherit.aes = TRUE, ...) {
    layer(
        stat = StatBspline2, data = data, mapping = mapping, geom = geom,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, n=n, ...)
    )
}
#' @rdname geom_bspline
#' @importFrom ggplot2 layer
#' @export
geom_bspline2 <- function(mapping = NULL, data = NULL, stat = "bspline2",
                         position = "identity", arrow = NULL, n = 100,
                         lineend = "butt", na.rm = FALSE, show.legend = NA,
                         inherit.aes = TRUE, ...) {
    layer(data = data, mapping = mapping, stat = stat, geom = GeomPathInterpolate,
          position = position, show.legend = show.legend, inherit.aes = inherit.aes,
          params = list(arrow = arrow, lineend = lineend, na.rm = na.rm, n=n, ...))
}
#' @rdname ggforce-extensions
#' @format NULL
#' @usage NULL
#' @importFrom grid xsplineGrob gpar
#' @importFrom ggplot2 ggproto GeomPath alpha
#' @export
GeomBspline0 <- ggproto('GeomBspline0', GeomPath,
    draw_panel = function(data, panel_scales, coord, arrow = NULL,
                          lineend = "butt", linejoin = "round", linemitre = 1,
                          na.rm = FALSE) {
        coords <- coord$transform(data, panel_scales)
        startPoint <- match(unique(coords$group), coords$group)
        xsplineGrob(coords$x, coords$y, id = coords$group, default.units = "native",
                    shape = 1,arrow = arrow,
                    gp = gpar(col = alpha(coords$colour[startPoint], coords$alpha[startPoint]),
                             lwd = coords$size[startPoint] * .pt,
                             lty = coords$linetype[startPoint], lineend = lineend,
                             linejoin = linejoin, linemitre = linemitre))
    }
)
#' @rdname geom_bspline
#' @importFrom ggplot2 layer StatIdentity
#' @export
stat_bspline0  <- function(mapping = NULL, data = NULL, geom = "bspline0",
                          position = "identity", na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE, ...) {
    layer(
        stat = StatIdentity, data = data, mapping = mapping, geom = geom,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, ...)
    )
}
#' @rdname geom_bspline
#' @importFrom ggplot2 layer
#' @export
geom_bspline0 <- function(mapping = NULL, data = NULL, stat = "identity",
                         position = "identity", arrow = NULL, lineend = "butt",
                         na.rm = FALSE, show.legend = NA, inherit.aes = TRUE,
                         ...) {
    layer(data = data, mapping = mapping, stat = stat, geom = GeomBspline0,
          position = position, show.legend = show.legend, inherit.aes = inherit.aes,
          params = list(arrow = arrow, lineend = lineend, na.rm = na.rm, ...))
}
