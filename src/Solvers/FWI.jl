function FWI{T<:AbstractFloat}(vp0::Array{T,2},d::Array{T,3},wav::Array{T,1},isz::Array{Int,1},isx::Array{Int,1},igz::Array{Int,1},igx::Array{Int,1},ot::Array{T,1},fmin::T,fmax::T,nf::Int,dz::T,dx::T,dt::T,ext::Int=50,atten_max::T=2.,alpha=1,GNiter=5,CGiter=20,CGtol=1.0e-15)

# This function performs frequency-domain acoustic full waveform inversion
# using the Gauss-Newton method. A multi-scale approach is adopted by 
# fitting the lowest frequencies first. The data is assumed to consist of
# time-domain shot gathers that have been organized into a data cube such 
# that the three dimensions are number of time steps, number of receivers, 
# and number of shots, respectively. It is assumed that each shot uses the
# same array of receivers (receivers are not moved) and has the same duration
# for the recording period. Additionally, it is assumed that each shot has 
# the same source wavelet.
#
# INPUTS:     vp0       - Initial guess for the velocity model
#             d         - Data (time domain shot gathers) orgaized into a cube with dimensions nt,ng,ns
#             wav       - Source wavelet (time domain)
#             isz       - z-indices for source locations
#             isx       - x-indices for source locations
#             igz       - z-indices for receiver locations
#             igx       - x-indices for receiver locations
#             ot        - Activation time for each of the sources
#             fmin      - Minimum frequency to model
#             fmax      - Maximum frequency to model
#             nf        - Number of frequency bins; 'nf' must be greater than or equal to 'length(wav)'
#             dz        - Grid spacing in z-direction
#             dx        - Grid spacing in x-direction
#             dt        - Sampling interval (time step)
#             ext       - Thickness (number of grid points) of absorbing boundary region
#             atten_max - Maximum complex amplitude in the attenuating boundary layer
#             alpha     - Step size in gradient descent method; how far to step along the gradient
#             GNiter    - Maximum number of iterations for the Gauss-Newton method
#             CGiter    - Maximum number of iterations for conjugate gradients
#             CGtol     - Convergence tolerance for conjugate gradients
#
# OUTPUTS:    vp        - Estimated velocity model

    nz = size(vp0,1) + 2*ext
    nx = size(vp0,2) + 2*ext
    nt = size(d,1)
    ng = size(d,2)
    ns = size(d,3)

    L = Laplacian(nz,nx,dz,dx)
    A = Attenuation(nz,nx,ext,atten_max)
    M = SlownessSquared(vp0,nz,nx,ext)
    R = Restriction(nz,nx,ext,igz,igx)

    D = fft([d ; zeros(nf-nt,ng,ns)],1)
    WAV = fft([wav;zeros(nf-length(wav))])
    fs = 1/dt
    df = fs/nf
    faxis = fftshift(-fs/2:df:fs/2-df)
    waxis = 2*pi*faxis

    _,iwmin = findmin(abs(fmin-faxis))
    _,iwmax = findmin(abs(fmax-faxis))

    ###########param = Dict(:R=>R,: )

### NEED TO IMPLEMENT PARALLELISM OVER SHOTS WHENEVER LOOPING OVER SHOTS... INCLUDING IN THE SENSITIVITY FUNCTION
    for iw = iwmin:iwmax
        w = waxis[iw]
        s = zeros(eltype(D),nz*nx,ns)
        for ishot = 1:ns
            s[:,ishot] = Source(isz,isx,ot,WAV,waxis,w,nz,nx,ext)
        end
        for iter = 1:GNiter
            H = lufact(L + w^2*M*A)
            U = zeros(eltype(D),nz,nx,ns)
            r = zeros(eltype(D),ng*ns)
            for ishot = 1:ns
                U[:,:,ishot] = H\s[:,ishot]
                r[(ishot-1)*ng+1:ishot*ng] = R*U[:,:,ishot] - D[iw,:,ishot]
            end
            dM = ConjugateGradients(r,[Sensitivity],param,Niter=CGiter,mu=0.,tol=CGtol)
            M -= dM # or should it be += ....?????
        end
    end

    vp = reshape(sqrt(1./diag(M)),nz,nx)[ext+1:end-ext,ext+1:end-ext]

    return vp

end
