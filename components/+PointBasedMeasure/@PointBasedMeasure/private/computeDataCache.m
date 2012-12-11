% Builds a tree of cache data indexed by pairs of indices
% This creates a single cache store shared among all instances
function data = computeDataCache(this,ka,kb)

    persistent cacheData

    kastr=['a',sprintf('%d',ka)];
    kbstr=['b',sprintf('%d',kb)];
    
    [use, IntermediateData] = computeIntermediateDataCache(this,ka,kb);
    
    if( isfield(cacheData,kastr) && isfield(cacheData.(kastr),kbstr) )
        data = cacheData.(kastr).(kbstr);
    else
        [data,IntermediateData] = RefineTrajectory(IntermediateData);
        cacheData.(kastr).(kbstr) = data;   
        
        Plot_Reporjection_omar(IntermediateData.nonNormalizedMatches,data.corrS,data.corrP,data.corrK,data.corrR,data.corrT,data.imageA,data.imageB,ka,kb,this.DisplayReprojection,this.DisplayReprojectionOnPictures,this.PauseBetweenImages);       
    end
        
end