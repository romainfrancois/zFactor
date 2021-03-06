# Dranchuk, Purvis, and Robinson (1974) developed a correlation based on the
# Benedict-Webb-Rubin type of equation of state. Fitting the equation to 1500
# data points from the Standing and Katz Z-factor chart optimized the eight
# coefficients of the proposed equations. From Traker Ahmed's book.

#' Dranchuk-Purvis-Robinson correlation
#'
#' @param pres.pr pseudo-reduced pressure
#' @param temp.pr pseudo-reduced temperature
#' @param tolerance controls the iteration accuracy
#' @param verbose print internal
#' @rdname Dranchuk-Purvis-Robinson
#' @export
#' @examples
#' ## calculate for one Tpr curve at a Ppr
#' z.DranchukPurvisRobinson(pres.pr = 1.5, temp.pr = 2.0)
#'
#' ## For vectors of Ppr and Tpr:
#' ppr <- c(0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5)
#' tpr <- c(1.3, 1.5, 1.7, 2)
#' z.DranchukPurvisRobinson(pres.pr = ppr, temp.pr = tpr)
#'
#' ## create a matrix of z values
#' tpr2 <- c(1.05, 1.1, 1.2, 1.3)
#' ppr2 <- c(0.5, 1.0, 1.5, 2, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5)
#' sk_corr_2 <- createTidyFromMatrix(ppr2, tpr2, correlation = "DPR")
#' tibble::as.tibble(sk_corr_2)
z.DranchukPurvisRobinson <- function(pres.pr, temp.pr, tolerance = 1E-13,
                                     verbose = FALSE) {

    co <- sapply(pres.pr, function(x)
        sapply(temp.pr, function(y)
            .z.DranchukPurvisRobinson(pres.pr = x, temp.pr = y,
                                      tolerance = tolerance, verbose = verbose)))
    if (length(pres.pr) > 1 || length(temp.pr) > 1) {
        co <- matrix(co, nrow = length(temp.pr), ncol = length(pres.pr))
        rownames(co) <- temp.pr
        colnames(co) <- pres.pr
    }
    return(co)
}


.z.DranchukPurvisRobinson <- function(pres.pr, temp.pr, tolerance = 1E-13,
                                     verbose = FALSE) {
    F <- function(rhor) {
        1 + T1 * rhor + T2 * rhor^2 + T3 * rhor^5 +
            (T4 * rhor^2 * (1 + A8 * rhor^2) * exp(-A8 * rhor^2)) - T5 / rhor
    }

    Fprime <- function(rhor) {
        T1 + 2 * T2 * rhor + 5 * T3 * rhor^4 +
            2 * T4 * rhor * exp(-A8 * rhor^2) *
            ((1 + 2 * A8 * rhor^2) - A8 * rhor^2 * (1 + A8 * rhor^2)) +
            T5 / rhor^2
    }

    A1 <- 0.31506237
    A2 <- -1.0467099
    A3 <- -0.57832720
    A4 <-  0.53530771
    A5 <- -0.61232032
    A6 <- -0.10488813
    A7 <- 0.68157001
    A8 <- 0.68446549

    T1 <- A1 + A2 / temp.pr + A3 / temp.pr^3
    T2 <- A4 + A5 / temp.pr
    T3 <- A5 * A6 / temp.pr
    T4 <- A7 / temp.pr^3
    T5 <- 0.27 * pres.pr / temp.pr

    rhork0 <- 0.27 * pres.pr / temp.pr    # initial guess
    rhork <- rhork0
    i <- 1
    while (TRUE) {
        if (abs(F(rhork)) < tolerance)  break
        rhork1 <- rhork - F(rhork) / Fprime(rhork)
        delta <- abs(rhork - rhork1)
        if (delta < tolerance) break
        if (verbose)
            cat(sprintf("%3d %11f %11f %11f \n", i, rhork, rhork1, delta))
        rhork <- rhork1
        i <- i + 1
    }
    z <- 0.27 * pres.pr / (rhork * temp.pr)
    return(z)
}