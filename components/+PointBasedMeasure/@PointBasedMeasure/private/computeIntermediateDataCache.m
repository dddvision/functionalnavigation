% Builds a tree of cache data indexed by pairs of indices
% This creates a single cache store shared among all instances
% 
% OUTPUT:
% use: is the valueindicating wether or not to use the imagePair
% stdZ: standard deviation in Z values 
% IntermediateData: all data calculated from Point Matching and
% decomposition (used in RefineTrajectory)
function [use, IntermediateData] = computeIntermediateDataCache(this,ka,kb)

    persistent cacheIntermediate

    kastr=['a',sprintf('%d',ka)];
    kbstr=['b',sprintf('%d',kb)];
    
    if( isfield(cacheIntermediate,kastr) && isfield(cacheIntermediate.(kastr),kbstr) )
        IntermediateData = cacheIntermediate.(kastr).(kbstr).IntermediateData;
        use = cacheIntermediate.(kastr).(kbstr).use;
    else      
        ia=getImage(this.sensor,ka);
        ib=getImage(this.sensor,kb);  
        if(~all(size(ia)==size(ib)))
           use = 0;
           return;
        end
        
        IntermediateData = computeIntermediateData(this,ia,ib);
        % Check if points are situated along the z-axis (degenerate strcuture)
        
        use = ( IntermediateData.FHRatio<PointBasedMeasure.PointBasedMeasureConfig.HFThreshold );
        
        cacheIntermediate.(kastr).(kbstr) = struct( 'IntermediateData', IntermediateData, ...
                                                    'use', use);
    end
        

end
