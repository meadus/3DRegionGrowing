
function [reg] = regionGrowing(img,noGo,seedInd,thresh)
% 3D region growing algorithm, returns the grown region (reg) as a logical array

% img = desired image to be masked, 3D array
% noGo = 3D array, same size as image, definining regions which should not be grown into
% seedInd = seeding pixel in index form (use sub2ind if x y z is known)
% thresh = maximum difference between the average of the region and a new pixel on the boundary to be added

%initialize
s = size(img);
reg = false(s);
new_reg = false(s);
reg(seedInd) = 1;
new_reg(seedInd) = 1;
addedPix = 1;

% defines what pixels (relative to seed) should be checked
neigh = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];

while addedPix %continues until no more pixels are added to the region
    
    seeds = find(new_reg(:)>0); %new potential pixels
    m = mean(img(reg));
    addedPix = 0;
    
    for i = 1:length(seeds)
        
        [y,x,z] = ind2sub(s,seeds(i)); %switched to subscripts so the neighbourhood (neigh) can be applied easily 
        seedSub = [y,x,z];
        
        if (y ~= 1)&&(x ~= 1)&&(z ~= 1)&&(y ~= s(1))&&(x ~= s(2))&&(z ~= s(3)) % array boundary?
            
            for ii = 1:6 %checks all neighborhood pixels
                
                sub = seedSub+neigh(ii,:);
                ind = sub2ind(s,sub(1),sub(2),sub(3));
                
                if (reg(ind) == 0)&&(new_reg(ind) == 0)&&(noGo(ind) == 0) % new pixel?
                    
                    diff = abs(img(ind)-m);
                    
                    if diff<thresh % is within the threshold?
                        
                        new_reg(ind) = 1; %adding new pixels to be checked next iteration
                        addedPix = 1; %confirms something has been added, and that the while loop should continue
                        
                    end 
                end
            end
        end
        
        reg(seeds(i)) = 1; % adds checked seed pixels to the official region
        new_reg(seeds(i)) = 0; %removing already checked pixels (for speed)
        
    end
    
end

end


