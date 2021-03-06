function MassMatrix{T<:AbstractFloat}(vp::Array{T,2},nz::Int,nx::Int,ext::Int)

# This function builds the diagonal mass matrix/operator, where the elements
# of the main diagonal contain the slowness-squared (1 over velocity-squared)
# for each point in the modeling region AND the surrounding boundary region.
#
# INPUTS:     vp        - Acoustic velocity model
#             nz        - Number of grid points in z-direction INCLUDING the absorbing boundary region
#             nx        - Number of grid points in x-direction INCLUDING the absorbing boundary region
#             ext       - Thickness (number of grid points) of absorbing boundary region
#
# OUTPUTS:    M         - Diagonal matrix containing the slowness-squared for each point within the model and boundary region

    M = zeros(T,nz,nx)
    M[ext+1:end-ext,ext+1:end-ext] = 1./(vp.^2)
    M[1:ext,1:ext] = 1./(vp[1,1].^2)
    M[1:ext,nx-ext+1:nx] = 1./(vp[1,end].^2)
    M[nz-ext+1:nz,1:ext] = 1./(vp[end,1].^2)
    M[nz-ext+1:nz,nx-ext+1:nx] = 1./(vp[end,end].^2)
    M[ext+1:nz-ext,1:ext] = 1./(kron(vp[:,1],ones(1,ext)).^2)
    M[ext+1:nz-ext,nx-ext+1:nx] = 1./(kron(vp[:,end],ones(1,ext)).^2)
    M[1:ext,ext+1:nx-ext] = 1./(kron(vp[1,:]',ones(ext,1)).^2)
    M[nz-ext+1:nz,ext+1:nx-ext] = 1./(kron(vp[end,:]',ones(ext,1)).^2)

    return spdiagm((M[:]),(0))

end