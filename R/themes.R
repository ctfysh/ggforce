#' Theme without axes and gridlines
#'
#' This theme is a simple wrapper around any complete theme that removes the
#' axis text, title and ticks as well as the grid lines for plots where these
#' have little meaning.
#'
#' @param base.theme The theme to use as a base for the new theme. Defaults to
#' \code{\link[ggplot2]{theme_bw}()}.
#'
#' @return A modified version of base.theme
#'
#' @examples
#' p <- ggplot() + geom_point(aes(x = wt, y = qsec), data = mtcars)
#'
#' p + theme_no_axes()
#' p + theme_no_axes(theme_grey())
#'
#' @importFrom ggplot2 theme_bw theme element_blank %+replace%
#' @export
#'
theme_no_axes <- function(base.theme = theme_bw()) {
    base.theme %+replace%
        theme(axis.text=element_blank(),
              axis.title=element_blank(),
              axis.ticks=element_blank(),
              panel.grid=element_blank())
}
