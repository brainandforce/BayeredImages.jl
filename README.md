# BayeredImages.jl

[![Build Status][ci-status-img]][ci-status-url]
[![Aqua.jl][aqua-img]][aqua-url]

This package provides types for working with raw data from color cameras, which generally use a color filter array (CFA).

The most common CFA (the Bayer matrix) is supported, but we also plan to provide support for the Fujifilm X-Trans matrix, and allow users to define custom types for unusual choices of CFA.
We also intend to add demosaicing algorithms in the future.

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
