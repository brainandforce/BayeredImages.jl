module BayeredImagesFITSIOExt

using BayeredImages
using FITSIO

import BayeredImages: BayerCFA, BayeredImage

"""
    BayerCFA(hdu::HDU)
    BayerCFA(fits::FITS, index = 1)

Generates the Bayer matrix associated with a FITS file.
Raw images taken with a camera using a Bayer color filter array will generally include the
keyword `"BAYERPAT"`, which encodes the arrangement of the Bayer matrix in a format string.
"""
function BayerCFA(hdu::HDU)
    bayerpat = try
        read_key(hdu, "BAYERPAT")
    catch
        throw(KeyError("BAYERPAT"))
    end
    return BayerCFA(first(bayerpat))
end

BayerCFA(fits::FITS, hduindex = 1) = BayerCFA(fits[hduindex])

function BayeredImage(hdu::ImageHDU)
    cfa = try
        BayerCFA(hdu)
    catch e
        e isa KeyError && @error "The BAYERPAT keyword is missing. Is this a CFA image?"
        rethrow()
    end
    return BayeredImage(cfa, read(hdu))
end

BayeredImage(fits::FITS, hduindex = 1) = BayeredImage(fits[hduindex])

# TODO: get a section of the image with array indices

BayeredImage(::HDU) = error("this HDU does not contain an image")

end