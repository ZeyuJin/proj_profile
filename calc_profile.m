function [lx,ly] = calc_profile(xx,yy,ph,A,B,varargin)
    % compute the profile across two points in utm coordinates
    if nargin == 5
        ninv = 100;
    else
        ninv = varargin{1};
    end
    
    px = linspace(A(1),B(1),ninv);
    py = linspace(A(2),B(2),ninv);
    ly = griddata(xx,yy,double(ph),px,py);
    lx = sqrt((px - px(1)).^2 + (py - py(1)).^2);
    lx = lx - mean(lx);
    
end