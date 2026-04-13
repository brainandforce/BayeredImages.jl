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

"""
    BayeredImage(hdu::ImageHDU; permute = true)
    BayeredImage(fits::FITS, index=1; permute = true)

Constructs a `BayeredImage` from the specified header data unit of a FITS file.

If `permute = true`, the rows and columns of the output are permuted to comply with Julia
column-first indexing.
"""
function BayeredImage(hdu::ImageHDU; permute=true)
    cfa = try
        permute ? permutedims(BayerCFA(hdu)) : BayerCFA(hdu)
    catch e
        e isa KeyError && @error "The BAYERPAT keyword is missing. Is this a CFA image?"
        rethrow()
    end
    # Read the image with the correct row order
    data = permute ? permutedims(read(hdu)) : read(hdu)
    roworder = try
        uppercase(first(read_key(hdu, "ROWORDER")))
    catch
        "BOTTOM-UP"
    end
    # Bottom-up is the default
    # Only reverse if TOP-DOWN is explicitly stated
    roworder == "TOP-DOWN" && reverse!(data, dims=1)
    return BayeredImage(cfa, data)
end

BayeredImage(fits::FITS, hduindex = 1; permute = true) = BayeredImage(fits[hduindex]; permute)

# TODO: get a section of the image with array indices

BayeredImage(::HDU) = error("this HDU does not contain an image")

end