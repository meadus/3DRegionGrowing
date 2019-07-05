function mask = iterativeRegionGrow(img,seeds,offset,ratio,minimum_growth,n_step_seeds, n_back_seeds)
% iterativeRegionGrow(img, seeds, offset, ratio, minimum_growth, n_step_seeds, n_back_seeds)
% Iterative region growing lung masking algorithm. Applies a region
% growing .mex file (C++). After growing a new set of seeds is chosen from
% the current region. This is done a slice by slice basis, where the
% minimum and maximum values are taken. Growing and re-seeding process
% continue until not enough pixels are added (meaning it's near
% completion).
%
% img == lung image, works best if normalized
% seeds == starting set of seed points
% offset/ratio == determines region growing inclusion criterion where the
% threshold is: thresh = seed_value/ratio + offset
% minimum_growth == stop condition, ends iterative process if less pixels
% than this were added
% n_step_seeds == how many slices to step through before taking a new seed
% n_back_seeds == how many back slices need seed points (the back tended to
% need extra attention due to large gradients)
%
% W. Quinn Meadus, June 2019

s = size(img);
mask = false(s);
growing = 1;

while growing
    mask_size_before = sum(mask(:));
    
    %growing from each seed in the current set
    for i = 1:length(seeds)
        if img(seeds(i)) > 0.7
            %skips seed if it is too large, helps prevent this from
            %escaping the lungs
            continue
        end
        
        %region growing
        thresh = img(seeds(i))/ratio+offset; %inclusion criterion
        [d1,d2,d3] = ind2sub(s,seeds(i));
        region = RegionGrowing(img,thresh,[d1 d2 d3]);
        
        %adds to the overall region
        mask = mask | region;
    end
    
    %stopping criteria, tests how much mask was added in the current
    %iteration
    mask_size_after = sum(mask(:));
    if (mask_size_after - mask_size_before) < minimum_growth
        break
    end
    
    %determining the next set of seeds to grow from
    seeds = [];
    for i = 1:s(3)
        sMask = mask(:,:,i);
        sImg = img(:,:,i);
        if sum(sMask(:)) ~= 0
            sliceInds = find(sMask);
            
            %maximum pixel value on each slice
            [~,ind] = max(sImg(sMask));
            sSeed = sliceInds(ind)+(i-1)*s(1)*s(2);
            seeds = [seeds;sSeed];
            
            %minimum seed value on each slice
            [~,ind] = min(sImg(sMask));
            sSeed = sliceInds(ind)+(i-1)*s(1)*s(2);
            seeds = [seeds;sSeed];
        end
    end
    
    %makes the complete set of new seeds depending on chosen parameters
    seeds1 = seeds(1:n_step_seeds:end);
    seeds2 = seeds(2:n_step_seeds:end);
    seeds3 = seeds(end-n_back_seeds:end);
    seeds = [seeds1;seeds2;seeds3];
    
end