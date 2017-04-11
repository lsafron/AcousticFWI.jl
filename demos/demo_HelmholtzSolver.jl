using AcousticFWI,Seismic,PyPlot

function main()

    nz = 150
    nx = 250
    nt = 500
    nf = 1024
    dz = 2.
    dx = 2.
    dt = 0.002
    f0 = 45.
    fmin = 2. 
    fmax = 120.
    ext = 50
    atten_max = 2.

    vp = 2000.*ones(nz,nx)
    vp[101:end,:] = 3000.

    wav = Ricker(f0=f0,dt=dt)
    wav = append!(wav,zeros(eltype(wav),Int(nt)-length(wav)))

    isz = [3,3]
    isx = [81,167]
    igz = 3*ones(Int,nx)
    igx = [1:nx;]
    ot = [0.,30*dt]

    u = HelmholtzSolver(isz,isx,ot,vp,wav,fmin,fmax,nf,nt,dz,dx,dt,ext,atten_max)
    d = u[:,3,igx]

    subplot(3,3,1) ; SeisPlot(u[20,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,2) ; SeisPlot(u[40,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,3) ; SeisPlot(u[60,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,4) ; SeisPlot(u[80,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,5) ; SeisPlot(u[100,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,6) ; SeisPlot(u[120,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,7) ; SeisPlot(u[140,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,8) ; SeisPlot(u[160,:,:],pclip=100,cmap="gray",fignum=1)
    subplot(3,3,9) ; SeisPlot(u[180,:,:],pclip=100,cmap="gray",fignum=1)

    SeisPlot(d,pclip=98,cmap="gray",fignum=2)

end

main()