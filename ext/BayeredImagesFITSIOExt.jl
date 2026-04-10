module BayeredImagesFITSIOExt

using BayeredImages
using FITSIO

import BayeredImages: BayerCFA

"""
    BayerCFA(hdu::HDU)
    BayerCFA(fits::FITS, index = 1)

Generates the Bayer matrix associated with a FITS file.
Raw images taken with a camera using a Bayer color filter array will generally include the
keyword `"BAYERPAT"`, which encodes the arrangement of the Bayer matrix in a format string.
"""
BayerCFA(hdu::HDU) = BayerCFA(first(read_key(hdu, "BAYERPAT")))
BayerCFA(fits::FITS, index = 1) = BayerCFA(fits[index])

end