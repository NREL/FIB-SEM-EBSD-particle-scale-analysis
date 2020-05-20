function BW_iq_comb = function_combine_grains_webs(BW_grains, BW_web)
%function_combine_grains_webs merges cleaned webbing and grains
%   BW_iq_comb =  function_combine_grains_webs(a,b) does ....
%   
%   Inputs
%       BW_grains - segmented grains as with NaNs filling in locations
%           where grains were removed
%       BW_web - segemented webbing wehre
% 
%   Outputs
%       BW_iq_comb - matrix where 1 == webbing and any other nubmer greater
%           than 1 is a grain region
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    BW_grains = BW_grains + 1;
    BW_grains(BW_grains == 1) = 0;
    BW_grains(isnan(BW_grains)) = 1; % isnan converted to webbing
    
    for n = 1:numel(BW_web) % per pixel in BW_web
        if BW_web(n) ~= 0 % if that location in BW_web > 0
            BW_grains(n) = 1; % then fill in BW_grains with the webbing there
        end
    end

    BW_iq_comb = BW_grains;
end