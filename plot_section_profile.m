function plot_section_profile(filepath,polygon_file,profile_file,data_file,dip_angle,indx,varargin)
% this function is to plot the section profile across the fault
% e.g. seismicity distribution, GPS or LOS displacements
% all the data within the polygon are projected onto that profile plane
% polygon_file and profile_file are in the format as: lon / lat
% data_file is in the format as: lon / lat / z_value
% written by Zeyu Jin on Oct. 31st, 2019
   addpath('/Users/zej011/work/Kang_tutorial/codes_utilities/matlab/igppsar');
   
   this_track = filepath;
   dpolygon = load([this_track,'/',polygon_file]);
   dprofile = load([this_track,'/',profile_file]);
   data = load([this_track,'/',data_file]);
   
   % choose the data within the polygon
   xv = dpolygon(:,1);  yv = dpolygon(:,2);
   xd = data(:,1);      yd = data(:,2);    zd = data(:,3) * (-1);
   in = inpolygon(xd,yd,xv,yv);
   lon_in = xd(in);     lat_in = yd(in);       zd_in = zd(in);
   [xlon,ylat] = utm2ll(lon_in,lat_in,0,1);
   
   % use the subroutine compute_cross.m to compute the projection points
   lon_ref1 = dprofile(1,1);  lat_ref1 = dprofile(1,2);
   lon_ref2 = dprofile(2,1);  lat_ref2 = dprofile(2,2);
   [xref1,yref1] = utm2ll(lon_ref1,lat_ref1,0,1);
   [xref2,yref2] = utm2ll(lon_ref2,lat_ref2,0,1);
   [xlon_p,ylat_p,~]=compute_cross(xlon,ylat,xref1,yref1,xref2,yref2);
   
   % rotate the coordinates parallel to the profile axis
   dx = xref2 - xref1;
   dy = yref2 - yref1;
   theta = atan2(dy,dx);
   [new_xp,new_yp] = xy2XY(xlon_p,ylat_p,theta);    % new_yp should be constant shift
%    disp(mean(new_yp - mean(new_yp)));             % only for test
   
   % if varargin exist, the user should provide two-end coordinates of the
   % fault, in the form of [lon1,lat1,lon2,lat2]
   if ~isempty(varargin)
       faults_proj = zeros(nargin-6,2);
       for ii = 1:nargin-6
           this_fault = varargin{ii};
           [xf1,yf1] = utm2ll(this_fault(1),this_fault(2),0,1);
           [xfp1,yfp1] = compute_cross(xf1,yf1,xref1,yref1,xref2,yref2);
           [new_xfp1,new_yfp1] = xy2XY(xfp1,yfp1,theta);
           
           [xf2,yf2] = utm2ll(this_fault(3),this_fault(4),0,1);
           [xfp2,yfp2] = compute_cross(xf2,yf2,xref1,yref1,xref2,yref2);
           [new_xfp2,new_yfp2] = xy2XY(xfp2,yfp2,theta);
           faults_proj(ii,:) = [new_xfp1,new_xfp2];
       end
   end
   
   % plot the profile symmetrically
   origin_x = mean(new_xp);   
   dist_along = (new_xp - origin_x) ./ 1000;
%    x1 = min(dist_along);   x2 = max(dist_along);
   faults_proj = (faults_proj - origin_x) ./ 1000;    % two ends of the fault
   sz = 25;
   figure; hold on
   for ii = 1:nargin-6
       XX = faults_proj(ii,:);
       YY = [0 0];
       if XX(1) == XX(2)
           scatter([0 0],YY,100,'r','filled');
       else
           plot(XX,YY,'*-','linewidth',10);
       end
   end
   xshift = XX(1);    % consider the profile shift when choose the polygon
   X_bottom = 10 * cosd(dip_angle);
   scatter(dist_along-xshift,zd_in,sz,'k','filled');
   x_dist = dist_along-xshift;
   save_scatter = [x_dist,zd_in];

   line([X_bottom,0],[-10,0],'linewidth',3,'color','magenta');
   line([-10,10],[-10,-10],'linewidth',3,'linestyle','--','color','blue');
   xlabel('Distance along the profile (km)');
   ylabel('Seismicity depth (km)');
   title(['Profile ',num2str(indx)]);
   axis equal
   axis([-4 4 -10 0]);
   set(gca,'fontsize',20);
   set(gcf,'PaperPositionMode','auto');
   
   save(['/Users/zej011/Ridgecrest/data_resample/seismicity_profile/cross_seismicity/Hauksson_',num2str(indx),'.mat'],'save_scatter');
end