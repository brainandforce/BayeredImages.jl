# BayeredImages.jl

[![Build Status][ci-status-img]][ci-status-url]
[![Aqua.jl][aqua-img]][aqua-url]

This package provides types for working with raw data from color cameras, which generally use a color filter array (CFA).
This is done with the `CFAImage` type, which allows for basic image transformations (reflection, rotation, switching dimensions) on both the data and the color filter array associated with it.

The most common CFA (the Bayer matrix) is supported, but we also plan to provide support for the Fujifilm X-Trans matrix, and allow users to define custom types for unusual choices of CFA (such as those used in some smartphones).
At the moment, we support demosaicing through bilinear interpolation, but the architecture allows for custom demosaic algorithms to be implemented and applied to either generic or specific CFAs.

Loading and saving raw images is outside of the scope of BayeredImages.jl alone, but support will be provided in package extensions or external packages.
As of the time of writing (2026-04-12), the package has an extension for loading raw CFA images in FITS file image HDUs through [FITSIO.jl](https://github.com/JuliaAstro/FITSIO.jl) into a `BayeredImage`.

[repo-url]:         https://github.com/brainandforce/BayeredImages.jl
[docs-stable-img]:  https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]:  https://brainandforce.github.io/BayeredImages.jl/stable
[docs-dev-img]:     https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]:     https://brainandforce.github.io/BayeredImages.jl/dev
[ci-status-img]:    https://github.com/brainandforce/BayeredImages.jl/workflows/CI/badge.svg
[ci-status-url]:    https://github.com/brainandforce/BayeredImages.jl/actions
[aqua-img]:         https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg
[aqua-url]:         https://github.com/JuliaTesting/Aqua.jl
[codecov-img]:      https://codecov.io/gh/brainandforce/BayeredImages.jl/branch/main/graph/badge.svg
[codecov-url]:      https://codecov.io/gh/brainandforce/BayeredImages.jl/
