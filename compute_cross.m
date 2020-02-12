function [xlon_p,ylat_p,dist]=compute_cross(xlon,ylat,xref1,yref1,xref2,yref2)
% compute_cross compute the cross-points
% xlon/ylat could be in the matrix form

d_sq=(xref1-xref2)^2+(yref1-yref2)^2;
k=-((xref1-xlon).*(xref2-xref1)+(yref1-ylat).*(yref2-yref1))/d_sq;

xlon_p=k.*(xref2-xref1)+xref1;
ylat_p=k.*(yref2-yref1)+yref1;


dist=sqrt((xlon-xlon_p).^2+(ylat-ylat_p).^2);
end

